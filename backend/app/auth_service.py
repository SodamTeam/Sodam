from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from passlib.context import CryptContext
from jose import jwt
import datetime

from .database import SessionLocal, engine, Base
from .models import User
from .schemas import UserCreate, UserOut, Token

# 설정
SECRET_KEY = "change_this_secret"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24

# bcrypt 해시 컨텍스트 (버전 호환성 문제 해결)
pwd_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto",
    bcrypt__rounds=12  # 기본 라운드 수 지정
)

# 테이블 생성
Base.metadata.create_all(bind=engine)

# DB 세션 의존성
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# 토큰 생성 헬퍼
def create_access_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.datetime.utcnow() + datetime.timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# 패스워드 헬퍼
def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)

# 라우터 정의
router = APIRouter(prefix="/api/auth", tags=["auth"])

@router.post("/signup", response_model=UserOut, status_code=201)
def signup(user: UserCreate, db: Session = Depends(get_db)):
    if db.query(User).filter(User.username == user.username).first():
        raise HTTPException(status_code=409, detail="이미 사용 중인 ID 입니다.")
    new_user = User(
        username=user.username,
        hashed_password=get_password_hash(user.pw),
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

# backend/app/auth_service.py  --- 하단 부분만
@router.post("/login", response_model=Token)
def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db),
):
    user = db.query(User).filter(User.username == form_data.username).first()
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="아이디 또는 비밀번호가 잘못되었습니다.",
        )

    # 토큰 생성
    access_token = create_access_token({"sub": user.username})

    # 정상 응답
    return {"access_token": access_token, "token_type": "bearer"}
