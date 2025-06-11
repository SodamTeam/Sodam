from pydantic import BaseModel
from typing import Optional

class ChatBase(BaseModel):
    user_id: int
    message: str

class ChatCreate(ChatBase):
    pass

class Chat(ChatBase):
    id: int
    response: str

    class Config:
        from_attributes = True

class ChatResponse(BaseModel):
    id: int
    user_id: int
    message: str
    response: str 