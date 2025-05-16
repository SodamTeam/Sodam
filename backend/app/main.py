from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.chat_service import router as chat_router

app = FastAPI()

# 개발용 CORS 설정 (배포 시에는 allow_origins를 실제 도메인만 허용)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# chat_service.py에 정의한 router 등록
app.include_router(chat_router, prefix="/api/generate")

@app.get("/health")
async def health_check():
    return {"status": "ok"}
