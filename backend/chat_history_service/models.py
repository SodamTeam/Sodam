# backend/chat-history-service/models.py
from sqlalchemy import Column, Integer, String, DateTime
from datetime import datetime
from .database import Base

class ChatHistory(Base):
    __tablename__ = "chat_history"

    id        = Column(Integer, primary_key=True, index=True)
    user_id   = Column(Integer, index=True, nullable=False)
    sender    = Column(String, nullable=False)     # "user" or "bot"
    content   = Column(String, nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow)
    room      = Column(String, index=True, nullable=False)