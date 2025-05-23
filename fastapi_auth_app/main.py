from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from . import models, database
from .routers import auth as auth_router

# DB 테이블 생성
models.Base.metadata.create_all(bind=database.engine)

app = FastAPI(title="Sodam Auth API")

# 💡  Flutter 프론트엔드에서 호출하려면 CORS 허용
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 실제 배포 시 도메인 명시
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router.router)

@app.get("/")
async def root():
    return {"msg": "Sodam Auth API working"}