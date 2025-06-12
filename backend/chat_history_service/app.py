from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from . import models, schemas, database

models.Base.metadata.create_all(bind=database.engine)

app = FastAPI(title="Chat History Service")

def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.post("/history/", response_model=schemas.ChatHistory)
def create_history(entry: schemas.ChatHistoryCreate, db: Session = Depends(get_db)):
    # entry.dict() 에 user_id, sender, content, room 이 포함됩니다
    db_entry = models.ChatHistory(**entry.dict())
    db.add(db_entry)
    db.commit()
    db.refresh(db_entry)
    return db_entry

@app.get("/history/{user_id}/{room}", response_model=list[schemas.ChatHistory])  # ◆ 수정
def read_history(user_id: int, room: str, db: Session = Depends(get_db)):        # ◆ 수정
    return (
        db.query(models.ChatHistory)
          .filter(models.ChatHistory.user_id == user_id,
                  models.ChatHistory.room    == room)                           # ◆ 추가 필터
          .order_by(models.ChatHistory.id)
          .all()
    )
