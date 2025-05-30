from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import subprocess
import sys
import os
from threading import Thread

from .auth_service import router as auth_router
from .chat_service import router as chat_router
from .profile_service import router as profile_router

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

def run_chat_server():
    chat_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), '..', 'chat-backend')
    if os.path.exists(chat_dir):
        os.chdir(chat_dir)
        # 포트 8001로 실행
        if sys.platform == 'win32':
            subprocess.run(['set', 'PORT=8001', '&&', 'npm', 'start'], shell=True)
        else:
            subprocess.run(['PORT=8001', 'npm', 'start'])

if __name__ == "__main__":
    # 채팅 서버를 별도 스레드에서 실행 (8001 포트)
    chat_thread = Thread(target=run_chat_server)
    chat_thread.daemon = True
    chat_thread.start()
    
    # 메인 FastAPI 서버 실행 (8003 포트)
    uvicorn.run(app, host="0.0.0.0", port=8003)