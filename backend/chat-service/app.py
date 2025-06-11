from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
import httpx
import os
import models
import schemas
import database
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Sodam Chat Service")

# CORS 설정 추가
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 데이터베이스 세션 의존성
def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

# API 설정
OLLAMA_API_URL = os.getenv("OLLAMA_API_URL", "http://localhost:11434/api/generate")
DEFAULT_MODEL = os.getenv("DEFAULT_MODEL", "gemma3:4b")
GOOGLE_BOOKS_API = "https://www.googleapis.com/books/v1/volumes"
API_GATEWAY_URL = "http://localhost:8000"  # API Gateway URL로 변경

class GenerateRequest(BaseModel):
    model: str
    prompt: str | None = None
    mode: str  # 'novel', 'analyze', 'poem', 'book'
    stream: bool = False
    system: str | None = None
    character: str | None = None
    name: str | None = None

class GenerateResponse(BaseModel):
    response: str

class ChatRequest(BaseModel):
    message: str
    character: str

class ChatResponse(BaseModel):
    response: str

@app.post("/generate", response_model=GenerateResponse)
async def generate(req: GenerateRequest):
    try:
        print(f"Generate request received: {req}")  # 요청 로깅
        
        # 프로필 서비스에서 캐릭터 정보 가져오기
        if req.character:
            print(f"Fetching profile for character: {req.character}")  # 프로필 요청 로깅
            async with httpx.AsyncClient() as client:
                profile_response = await client.get(f"{API_GATEWAY_URL}/api/profile/{req.character}")
                print(f"Profile response status: {profile_response.status_code}")  # 프로필 응답 로깅
                if profile_response.status_code == 200:
                    profile = profile_response.json()
                    system_name = req.name if req.name else profile['name']
                    req.system = f"""
                    네 이름은 {system_name}이야. 너는 {profile['description']}이야.
                    {profile['personality']}
                    관심사: {profile['interests']}
                    배경: {profile['background']}
                    항상 {system_name}으로서 대답해.
                    """
                    print(f"System prompt created: {req.system}")  # 시스템 프롬프트 로깅

        # 'book' 모드일 경우 Google Books API 사용
        if req.mode == "book":
            if not req.prompt:
                raise HTTPException(status_code=400, detail="책 키워드를 입력해주세요.")

            async with httpx.AsyncClient() as client:
                params = {
                    "q": req.prompt,
                    "maxResults": 3,
                    "printType": "books",
                    "langRestrict": "ko"
                }
                resp = await client.get(GOOGLE_BOOKS_API, params=params)
                if resp.status_code != 200:
                    raise HTTPException(status_code=resp.status_code, detail="Google Books API 오류")

                data = resp.json()
                books = data.get("items", [])
                if not books:
                    return GenerateResponse(response="추천할 책이 없습니다.")

                results = []
                for book in books:
                    info = book["volumeInfo"]
                    title = info.get("title", "제목 없음")
                    authors = ", ".join(info.get("authors", []))
                    desc = info.get("description", "설명이 없습니다.")
                    results.append(f"\U0001F4DA 제목: {title}\n\U0001F464 저자: {authors}\n\U0001F4DD 소개: {desc[:100]}...\n")

                return GenerateResponse(response="\n\n".join(results))

        # 'book' 이외 모드일 경우 LLM API 호출
        payload: dict = {
            "model": req.model,
            "prompt": req.prompt or "기본 프롬프트",
            "stream": req.stream,
        }
        if req.system:
            payload["system"] = req.system

        print(f"Sending request to Ollama: {payload}")  # Ollama 요청 로깅
        async with httpx.AsyncClient(timeout=180.0) as client:
            resp = await client.post(OLLAMA_API_URL, json=payload)
            print(f"Ollama response status: {resp.status_code}")  # Ollama 응답 상태 로깅
            print(f"Ollama response: {resp.text}")  # Ollama 응답 내용 로깅
            resp.raise_for_status()
            data = resp.json()

        result = data.get("response")
        if not result:
            raise HTTPException(status_code=500, detail="LLM 응답이 비어 있어요.")

        return GenerateResponse(response=result)

    except Exception as e:
        print(f"Error in generate: {str(e)}")  # 오류 로깅
        raise HTTPException(status_code=500, detail=f"서버 오류: {e}")

@app.post("/chat", response_model=schemas.ChatResponse)
async def create_chat(chat: schemas.ChatCreate, db: Session = Depends(get_db)):
    # Ollama API 호출
    async with httpx.AsyncClient() as client:
        response = await client.post(
            OLLAMA_API_URL,
            json={
                "model": DEFAULT_MODEL,
                "prompt": chat.message,
                "stream": False
            }
        )
        
        if response.status_code != 200:
            raise HTTPException(status_code=500, detail="Failed to generate response")
        
        ai_response = response.json()["response"]
    
    # 채팅 기록 저장
    db_chat = models.Chat(
        user_id=chat.user_id,
        message=chat.message,
        response=ai_response
    )
    db.add(db_chat)
    db.commit()
    db.refresh(db_chat)
    
    return db_chat

@app.get("/chat/history/{user_id}", response_model=List[schemas.Chat])
def get_chat_history(user_id: int, db: Session = Depends(get_db)):
    chats = db.query(models.Chat).filter(models.Chat.user_id == user_id).all()
    return chats

@app.post("/generate-response", response_model=ChatResponse)
async def generate_response(request: ChatRequest):
    try:
        # 프로필 서비스에서 캐릭터 정보 가져오기
        async with httpx.AsyncClient() as client:
            profile_response = await client.get(f"{API_GATEWAY_URL}/api/profile/{request.character}")  # API Gateway 사용
            if profile_response.status_code != 200:
                raise HTTPException(status_code=404, detail="Character not found")
            
            profile = profile_response.json()
            system_prompt = f"""
            너는 {profile['name']}이야. {profile['description']}
            {profile['personality']}
            관심사: {profile['interests']}
            배경: {profile['background']}
            """
            
            # 여기에 실제 AI 모델 호출 코드 추가
            # 임시로 에코 응답
            return ChatResponse(response=f"{profile['name']}: {request.message}")
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))