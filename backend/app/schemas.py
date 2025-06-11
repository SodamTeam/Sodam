from pydantic import BaseModel, constr

class UserCreate(BaseModel):
    username: constr(min_length=1, max_length=50)
    pw: constr(min_length=1)

class UserOut(BaseModel):
    id: int
    username: str
    class Config: orm_mode = True

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
