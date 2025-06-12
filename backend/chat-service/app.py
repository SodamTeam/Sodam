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
from fastapi.responses import StreamingResponse
import json

app = FastAPI(title="Sodam Chat Service")

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# DB 세션 의존성
def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

# API 설정
OLLAMA_API_URL = os.getenv("OLLAMA_API_URL", "http://localhost:11434/api/chat")
DEFAULT_MODEL = os.getenv("DEFAULT_MODEL", "gemma3:4b")
GOOGLE_BOOKS_API = "https://www.googleapis.com/books/v1/volumes"
API_GATEWAY_URL = "http://localhost:8000"

class GenerateRequest(BaseModel):
    user_id: int = 0
    model: str
    messages: List[dict] | None = None
    prompt: str | None = None
    mode: str  # 'novel', 'analyze', 'poem', 'book'
    stream: bool = True
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

@app.post("/api/chat/generate", response_model=GenerateResponse)
async def generate(req: GenerateRequest):
    try:
        if req.character:
            async with httpx.AsyncClient() as client:
                profile_response = await client.get(f"{API_GATEWAY_URL}/api/profile/{req.character}")
                if profile_response.status_code == 200:
                    profile = profile_response.json()
                    system_name = req.name if req.name else profile['name']
                    system_message = f"""
                    네 이름은 {system_name}이야. 너는 {profile['description']}이야.
                    {profile['personality']}
                    관심사: {profile['interests']}
                    배경: {profile['background']}
                    항상 {system_name}으로서 대답해.
                    """

        if req.mode == "book":
            if not req.prompt:
                raise HTTPException(status_code=400, detail="책 키워드를 입력해주세요.")
            try:
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
                    print(f"검색된 책 수: {len(books)}")  # 디버깅용 로그
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
            except Exception as e:
                print(f"Google Books API 호출 중 예외 발생: {str(e)}")  # 디버깅용 로그
                raise HTTPException(status_code=500, detail=f"Google Books API 호출 실패: {str(e)}")

        # Ollama API 호출을 위한 메시지 구성
        messages = []
        if req.system:
            messages.append({"role": "system", "content": req.system})
        if req.prompt:
            messages.append({"role": "user", "content": req.prompt})
        if req.messages:
            messages.extend(req.messages)

        payload = {
            "model": req.model,
            "messages": messages,
            "stream": req.stream,
        }

        if req.stream:
            async def stream_and_store():
                response_text = ""
                async with httpx.AsyncClient(timeout=30.0) as client:
                    async with client.stream('POST', OLLAMA_API_URL, json=payload) as response:
                        async for line in response.aiter_lines():
                            if line:
                                try:
                                    data = json.loads(line)
                                    if 'message' in data:
                                        yield f"data: {json.dumps({'response': data['message']['content']})}\n\n"
                                except json.JSONDecodeError:
                                    continue
                # DB 저장
                try:
                    async with database.SessionLocal() as db:
                        db_entry = models.ChatHistory(
                            user_id=req.user_id,
                            room=req.character or "default",
                            message=req.prompt or "",
                            response=response_text
                        )
                        db.add(db_entry)
                        db.commit()
                except Exception as e:
                    print(f"[DB 저장 오류] {e}")
            return StreamingResponse(stream_and_store(), media_type="text/event-stream")

        else:
            async with httpx.AsyncClient(timeout=30.0) as client:
                resp = await client.post(OLLAMA_API_URL, json=payload)
                resp.raise_for_status()
                data = resp.json()

            result = data.get("message", {}).get("content")
            if not result:
                raise HTTPException(status_code=500, detail="LLM 응답이 비어 있어요.")

            # DB 저장
            try:
                async with database.SessionLocal() as db:
                    db_entry = models.ChatHistory(
                        user_id=req.user_id,
                        room=req.character or "default",
                        message=req.prompt or "",
                        response=result
                    )
                    db.add(db_entry)
                    db.commit()
            except Exception as e:
                print(f"[DB 저장 오류] {e}")

            return GenerateResponse(response=result)

    except Exception as e:
        print(f"Error in generate: {str(e)}")
        raise HTTPException(status_code=500, detail=f"서버 오류: {e}")

@app.post("/generate", response_model=GenerateResponse)
async def generate_alias(request: GenerateRequest):
    # /api/chat/generate 로직을 그대로 호출하는 alias 엔드포인트
    return await generate(request)

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

@app.post("/api/chat/message")
async def save_message(message: dict):
    try:
        # 여기에 메시지 저장 로직 구현
        return {"status": "success"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))