from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from auth_service import router as auth_router
from chat_service import router as chat_router
from profile_service import router as profile_router

app = FastAPI(title="SODAM Backend Services")

# CORS (개발용: 모든 오리진 허용)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
    allow_credentials=True,
)

# 각 서비스 라우터
app.include_router(auth_router)
app.include_router(chat_router, prefix="/api/generate")
app.include_router(profile_router, prefix="/api/profile")

@app.get("/health")
async def health_check():
    return {"status": "ok"}