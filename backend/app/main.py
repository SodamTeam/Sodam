from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .chat_service import router as chat_router
from .profile_service import router as profile_router


app = FastAPI()

# 개발용 CORS 설정 (배포 시에는 allow_origins를 실제 도메인만 허용)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 실제 배포시에는 도메인 리스트로 제한하세요
    allow_methods=["*"],
    allow_headers=["*"],
)

# 라우터 등록
app.include_router(chat_router, prefix="/api/generate")
app.include_router(profile_router, prefix="/api/profile")

@app.get("/health")
async def health_check():
    return {"status": "ok"}

# 아래는 uvicorn을 통해 이 스크립트를 직접 실행할 때만 실행되는 부분입니다.
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
