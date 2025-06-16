from sqlalchemy import Column, Integer, String, Text
from database import Base

class Profile(Base):
    __tablename__ = "profiles"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    name = Column(String)
    description = Column(Text)
    image_url = Column(String)
    personality = Column(Text)
    interests = Column(Text)
    background = Column(Text) 