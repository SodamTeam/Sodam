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

OLLAMA_API_URL = os.getenv("OLLAMA_API_URL", "http://localhost:11434/api/generate")
DEFAULT_MODEL = os.getenv("DEFAULT_MODEL", "gemma3:4b")
GOOGLE_BOOKS_API = "https://www.googleapis.com/books/v1/volumes"
API_GATEWAY_URL = "http://localhost:8000"

class GenerateRequest(BaseModel):
    user_id: int = 0
    model: str
    prompt: str | None = None
    mode: str
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
        if req.character:
            async with httpx.AsyncClient() as client:
                profile_response = await client.get(f"{API_GATEWAY_URL}/api/profile/{req.character}")
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

        payload = {
            "model": req.model,
            "prompt": req.prompt or "기본 프롬프트",
            "stream": req.stream,
        }
        if req.system:
            payload["system"] = req.system

        if req.stream:
            async def stream_and_store():
                response_text = ""
                async with httpx.AsyncClient(timeout=30.0) as client:
                    async with client.stream('POST', OLLAMA_API_URL, json=payload) as response:
                        async for line in response.aiter_lines():
                            if line:
                                try:
                                    data = json.loads(line)
                                    chunk = data.get("response", "")
                                    response_text += chunk
                                    yield f"data: {json.dumps({'response': chunk})}\n\n"
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

            result = data.get("response")
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