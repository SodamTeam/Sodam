from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
import models
import schemas
import database

# 테이블 생성
database.Base.metadata.create_all(bind=database.engine)

app = FastAPI(title="Chat History Service")

# DB 세션 의존성
def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

# 채팅 기록 생성
@app.post("/history/", response_model=schemas.ChatHistory)
def create_history(entry: schemas.ChatHistoryCreate, db: Session = Depends(get_db)):
    db_entry = models.ChatHistory(**entry.dict())
    db.add(db_entry)
    db.commit()
    db.refresh(db_entry)
    return db_entry

# 특정 유저 + 방의 채팅 기록 조회
@app.get("/history/{user_id}/{room}", response_model=list[schemas.ChatHistory])
def read_history(user_id: int, room: str, db: Session = Depends(get_db)):
    return (
        db.query(models.ChatHistory)
          .filter(models.ChatHistory.user_id == user_id,
                  models.ChatHistory.room == room)
          .order_by(models.ChatHistory.id)
          .all()
    )
