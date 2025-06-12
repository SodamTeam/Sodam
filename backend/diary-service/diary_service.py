from fastapi import APIRouter, HTTPException, UploadFile, File
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List
import uuid
import sqlite3
import os

router = APIRouter()

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))  # gateway.py 기준으로 상위 폴더

DB_PATH = "emotion_diary.db"

# 감정일기 모델
class DiaryEntry(BaseModel):
    id: int | None = None
    date: str
    mood: str = ""
    category: str = ""
    content: str

# 감정일기 목록 조회
@router.get("/", response_model=List[DiaryEntry])
def get_entries():
    try:
        conn = sqlite3.connect(DB_PATH)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM diary_entries ORDER BY date DESC")
        rows = cursor.fetchall()
        entries = [DiaryEntry(**dict(row)) for row in rows]
        conn.close()
        return JSONResponse(
            content=[e.dict() for e in entries],
            media_type="application/json; charset=utf-8"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 감정일기 작성
@router.post("/", response_model=DiaryEntry)
def create_entry(entry: DiaryEntry):
    try:
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO diary_entries (date, mood, category, content) VALUES (?, ?, ?, ?)",
            (entry.date, entry.mood, entry.category, entry.content),
        )
        conn.commit()
        entry.id = cursor.lastrowid
        conn.close()
        return JSONResponse(
            content=entry.model_dump(),
            media_type="application/json; charset=utf-8"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/{id}", response_model=DiaryEntry)
def update_entry(id: int, entry: DiaryEntry):
    try:
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE diary_entries SET date=?, mood=?, category=?, content=? WHERE id=?",
            (entry.date, entry.mood, entry.category, entry.content, id)
        )
        conn.commit()
        conn.close()
        entry.id = id
        return JSONResponse(content=entry.model_dump(), media_type="application/json; charset=utf-8")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/{id}")
def delete_entry(id: int):
    try:
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        cursor.execute("DELETE FROM diary_entries WHERE id=?", (id,))
        conn.commit()
        conn.close()
        return {"message": "삭제되었습니다"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


def init_db():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS diary_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            mood TEXT,
            category TEXT,
            content TEXT
        )
    ''')
    conn.commit()
    conn.close()

init_db()  # 서버 시작 시 테이블 자동 생성