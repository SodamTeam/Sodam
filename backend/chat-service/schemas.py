# backend/chat-service/schemas.py

from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class ChatBase(BaseModel):
    user_id: int
    message: str

class ChatCreate(ChatBase):
    pass

class Chat(ChatBase):
    id: int
    response: str
    created_at: datetime

    class Config:
        orm_mode = True

class ChatResponse(Chat):
    pass 