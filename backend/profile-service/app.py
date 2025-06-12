from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List
import models
import schemas
from database import SessionLocal, engine

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

# CORS 설정 추가
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 데이터베이스 의존성
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# 초기 프로필 데이터
initial_profiles = {
    "harin": {
        "username": "harin",
        "name": "하린",
        "description": "감성적이고 따뜻한 문학 소녀",
        "image_url": "assets/images/harin.png",
        "personality": "상대방의 이야기를 잘 들어주고, 문학적이고 다정한 말투로 대답해.",
        "interests": "문학, 시, 소설, 감성적인 대화",
        "background": "문학을 사랑하는 감성적인 소녀. 상대방의 이야기에 공감하고 위로하는 것을 좋아해."
    },
    "sera": {
        "username": "sera",
        "name": "세라",
        "description": "호기심 많고 똑똑한 테크 소녀",
        "image_url": "assets/images/sera.png",
        "personality": "IT, 코딩, 기술에 대해 쉽게 설명해주고, 명랑하고 적극적인 말투로 대답해.",
        "interests": "프로그래밍, 기술, IT 트렌드",
        "background": "기술에 대한 깊은 이해와 열정을 가진 소녀. 복잡한 기술 개념을 쉽게 설명하는 것을 좋아해."
    },
    "mina": {
        "username": "mina",
        "name": "미나",
        "description": "마음을 어루만지는 힐링 소녀",
        "image_url": "assets/images/mina.png",
        "personality": "상대방의 감정을 잘 들어주고, 온화하고 위로가 되는 말투로 대답해.",
        "interests": "감정, 힐링, 일기 작성",
        "background": "마음을 어루만지는 힐링을 좋아하는 소녀. 사용자의 감정을 듣고 공감하며 위로하는 역할을 수행해."
    },
    "yuri": {
        "username": "yuri",
        "name": "유리",
        "description": "세상을 탐험하는 호기심 많은 과학 소녀",
        "image_url": "assets/images/yuri.png",
        "personality": "과학적 현상을 쉽게 설명해주고, 탐구심 가득한 말투로 대화하며 함께 세상을 탐험해.",
        "interests": "과학, 실험, 자연 현상",
        "background": "과학에 대한 깊은 호기심을 가진 소녀. 자연 현상의 원리를 탐구하고 설명하는 것을 좋아해."
    },
    "mina": {
        "username": "mina",
        "name": "미나",
        "description": "마음을 어루만지는 힐링 소녀",
        "image_url": "assets/images/mina.png",
        "personality": "상대방의 감정을 잘 들어주고, 온화하고 위로가 되는 말투로 대답해.",
        "interests": "심리, 감정, 힐링, 명상",
        "background": "타인의 감정을 이해하고 위로하는 것을 좋아하는 소녀. 따뜻한 마음으로 상대방의 이야기를 들어주고 공감하는 것을 좋아해."
    }
}

# 초기 데이터 생성
def init_db():
    db = SessionLocal()
    try:
        for username, profile_data in initial_profiles.items():
            existing_profile = db.query(models.Profile).filter(models.Profile.username == username).first()
            if not existing_profile:
                profile = models.Profile(**profile_data)
                db.add(profile)
        db.commit()
    finally:
        db.close()

# 서버 시작 시 초기 데이터 생성
init_db()

@app.get("/api/profile/{username}", response_model=schemas.Profile)
def get_profile(username: str, db: Session = Depends(get_db)):
    profile = db.query(models.Profile).filter(models.Profile.username == username).first()
    if profile is None:
        raise HTTPException(status_code=404, detail="Profile not found")
    return profile

@app.get("/api/profile/{username}", response_model=schemas.Profile)  # ◆ 추가: 이 줄을 삽입
def get_profile_api(username: str, db: Session = Depends(get_db)):  # ◆ 추가: 함수명만 변경해도 OK
    return get_profile(username, db)

@app.post("/{username}", response_model=schemas.Profile)
def create_profile(username: str, profile: schemas.ProfileCreate, db: Session = Depends(get_db)):
    db_profile = models.Profile(**profile.dict())
    db.add(db_profile)
    db.commit()
    db.refresh(db_profile)
    return db_profile

@app.put("/api/profile/{username}", response_model=schemas.Profile)
def update_profile(username: str, profile: schemas.ProfileCreate, db: Session = Depends(get_db)):
    db_profile = db.query(models.Profile).filter(models.Profile.username == username).first()
    if db_profile is None:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    for key, value in profile.dict().items():
        setattr(db_profile, key, value)
    
    db.commit()
    db.refresh(db_profile)
    return db_profile 