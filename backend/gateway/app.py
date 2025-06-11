from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
import httpx
import os

app = FastAPI(title="Sodam API Gateway")

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 실제 운영 환경에서는 특정 도메인만 허용하도록 수정
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 서비스 URL 설정
CHAT_SERVICE_URL = os.getenv("CHAT_SERVICE_URL", "http://localhost:8000")
AUTH_SERVICE_URL = os.getenv("AUTH_SERVICE_URL", "http://localhost:8001")
PROFILE_SERVICE_URL = os.getenv("PROFILE_SERVICE_URL", "http://localhost:8002")

# HTTP 클라이언트 설정
http_client = httpx.AsyncClient()

# 채팅 서비스 라우팅
@app.post("/api/chat/generate")
async def generate_chat(request: dict):
    try:
        response = await http_client.post(
            f"{CHAT_SERVICE_URL}/generate",
            json=request
        )
        return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/chat")
async def create_chat(request: dict):
    try:
        response = await http_client.post(
            f"{CHAT_SERVICE_URL}/chat",
            json=request
        )
        return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/chat/history/{user_id}")
async def get_chat_history(user_id: int):
    try:
        response = await http_client.get(
            f"{CHAT_SERVICE_URL}/chat/history/{user_id}"
        )
        return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 인증 서비스 라우팅
@app.post("/api/auth/login")
async def login(request: Request):
    try:
        # 요청 본문을 form-data 형식으로 변환
        form_data = await request.form()
        
        response = await http_client.post(
            f"{AUTH_SERVICE_URL}/login",
            data=dict(form_data),  # form-data로 전송
            headers={"Content-Type": "application/x-www-form-urlencoded"}
        )
        return response.json()
    except Exception as e:
        print(f"Login error: {str(e)}")  # 에러 로깅 추가
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/auth/signup")
async def signup(request: dict):
    try:
        response = await http_client.post(
            f"{AUTH_SERVICE_URL}/signup",
            json=request
        )
        return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/auth/users/me")
async def get_current_user(token: str):
    try:
        response = await http_client.get(
            f"{AUTH_SERVICE_URL}/users/me",
            headers={"Authorization": f"Bearer {token}"}
        )
        return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 프로필 서비스 라우팅
@app.get("/api/profile/{character}")
async def get_profile(character: str):
    try:
        response = await http_client.get(
            f"{PROFILE_SERVICE_URL}/{character}"
        )
        return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.on_event("shutdown")
async def shutdown_event():
    await http_client.aclose() 