# backend/chat-service/schemas.py

from pydantic import BaseModel
from typing import Optional

class ChatBase(BaseModel):
    message: str

class ChatCreate(ChatBase):
    pass

class Chat(ChatBase):
    user_id: int
    id: int
    response: str

    class Config:
        from_attributes = True

class ChatResponse(BaseModel):
    id: int
    user_id: int
    message: str
    response: str 