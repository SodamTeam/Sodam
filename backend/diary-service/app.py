# backend/diary-service/app.py
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List
import sqlite3
import os

app = FastAPI(title="Sodam Diary Service")

# CORS (개발용으로 전체 허용)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# DB 파일 경로
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, "emotion_diary.db")

# 모델 정의
class DiaryEntry(BaseModel):
    id: int | None = None
    date: str
    mood: str = ""
    category: str = ""
    content: str

# 테이블 자동 생성
def init_db():
    conn = sqlite3.connect(DB_PATH)
    conn.execute('''
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

init_db()

# — 리스트 조회
@app.get("/api/diary", response_model=List[DiaryEntry])
def list_diary():
    try:
        conn = sqlite3.connect(DB_PATH)
        conn.row_factory = sqlite3.Row
        rows = conn.execute("SELECT * FROM diary_entries ORDER BY date DESC").fetchall()
        conn.close()
        return [DiaryEntry(**dict(r)) for r in rows]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# — 새 일기 작성
@app.post("/api/diary", response_model=DiaryEntry)
def create_diary(entry: DiaryEntry):
    try:
        conn = sqlite3.connect(DB_PATH)
        cur = conn.cursor()
        cur.execute(
          "INSERT INTO diary_entries (date, mood, category, content) VALUES (?, ?, ?, ?)",
          (entry.date, entry.mood, entry.category, entry.content)
        )
        conn.commit()
        entry.id = cur.lastrowid
        conn.close()
        return entry
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# — 일기 수정
@app.put("/api/diary/{id}", response_model=DiaryEntry)
def update_diary(id: int, entry: DiaryEntry):
    try:
        conn = sqlite3.connect(DB_PATH)
        conn.execute(
          "UPDATE diary_entries SET date=?, mood=?, category=?, content=? WHERE id=?",
          (entry.date, entry.mood, entry.category, entry.content, id)
        )
        conn.commit()
        conn.close()
        entry.id = id
        return entry
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# — 일기 삭제
@app.delete("/api/diary/{id}")
def delete_diary(id: int):
    try:
        conn = sqlite3.connect(DB_PATH)
        conn.execute("DELETE FROM diary_entries WHERE id=?", (id,))
        conn.commit()
        conn.close()
        return {"message": "삭제되었습니다"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 헬스체크
@app.get("/health")
def health():
    return {"status": "diary-service OK"}
