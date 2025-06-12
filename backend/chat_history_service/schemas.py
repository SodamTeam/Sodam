# backend/chat-history-service/schemas.py
from pydantic import BaseModel
from datetime import datetime

class ChatHistoryBase(BaseModel):
    user_id: int
    sender: str
    content: str
    room: str  

class ChatHistoryCreate(ChatHistoryBase):
    pass

class ChatHistory(ChatHistoryBase):
    id: int
    timestamp: datetime

    class Config:
        orm_mode = True
