from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
import httpx
import os
from . import models, schemas, database

app = FastAPI(title="Sodam Chat Service")

# 데이터베이스 세션 의존성
def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Ollama API 설정
OLLAMA_API_URL = os.getenv("OLLAMA_API_URL", "http://localhost:11434/api/generate")
DEFAULT_MODEL = os.getenv("DEFAULT_MODEL", "gemma3:4b")

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