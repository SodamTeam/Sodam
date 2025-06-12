from pydantic import BaseModel

class ProfileBase(BaseModel):
    username: str
    name: str
    description: str
    image_url: str
    personality: str
    interests: str
    background: str

class ProfileCreate(ProfileBase):
    pass

class Profile(ProfileBase):
    id: int

    class Config:
        from_attributes = True 