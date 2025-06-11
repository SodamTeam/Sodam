from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
import httpx
import os
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import json

app = FastAPI(title="Sodam API Gateway")

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 서비스 URL 설정
CHAT_SERVICE_URL = "http://localhost:8001"  # chat-service
AUTH_SERVICE_URL = "http://localhost:8002"  # auth-service
PROFILE_SERVICE_URL = "http://localhost:8003"  # profile-service

# HTTP 클라이언트 설정
http_client = httpx.AsyncClient(timeout=30.0)

# 채팅 서비스 라우팅
@app.post("/api/chat/generate")
async def generate_chat(request: dict):
    try:
        print(f"Chat request: {request}")  # 디버깅용 로그
        response = await http_client.post(
            f"{CHAT_SERVICE_URL}/generate",
            json=request
        )
        print(f"Chat response: {response.status_code} - {response.text}")  # 디버깅용 로그
        return response.json()
    except Exception as e:
        print(f"Chat error: {str(e)}")  # 디버깅용 로그
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/chat/generate-stream")
async def generate_stream(request: Request):
    try:
        request_data = await request.json()
        print(f"Stream request received: {request_data}")  # 요청 데이터 로깅
        
        async def stream_response():
            try:
                print(f"Connecting to chat service: {CHAT_SERVICE_URL}/api/chat/generate-stream")  # 연결 로깅
                async with httpx.AsyncClient() as client:
                    async with client.stream(
                        'POST',
                        f"{CHAT_SERVICE_URL}/api/chat/generate-stream",
                        json=request_data,
                        timeout=30.0
                    ) as response:
                        print(f"Chat service response status: {response.status_code}")  # 응답 상태 로깅
                        if response.status_code != 200:
                            error_text = await response.text()
                            print(f"Chat service error: {error_text}")  # 오류 로깅
                            yield f"data: {json.dumps({'error': error_text})}\n\n"
                            return
                        
                        async for chunk in response.aiter_bytes():
                            print(f"Received chunk: {chunk}")  # 청크 로깅
                            yield chunk
            except Exception as e:
                print(f"Stream error in gateway: {str(e)}")  # 오류 로깅
                yield f"data: {json.dumps({'error': str(e)})}\n\n"

        return StreamingResponse(
            stream_response(),
            media_type="text/event-stream"
        )
    except Exception as e:
        print(f"Gateway error: {str(e)}")  # 오류 로깅
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
        form_data = await request.form()
        print(f"Login request data: {dict(form_data)}")  # 디버깅용 로그
        response = await http_client.post(
            f"{AUTH_SERVICE_URL}/login",
            data=dict(form_data),
            headers={"Content-Type": "application/x-www-form-urlencoded"}
        )
        print(f"Login response: {response.status_code} - {response.text}")  # 디버깅용 로그
        return response.json()
    except Exception as e:
        print(f"Login error: {str(e)}")  # 디버깅용 로그
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/auth/signup")
async def signup(request: Request):
    try:
        form_data = await request.form()
        print(f"Signup request data: {dict(form_data)}")  # 디버깅용 로그
        response = await http_client.post(
            f"{AUTH_SERVICE_URL}/signup",
            data=dict(form_data),
            headers={"Content-Type": "application/x-www-form-urlencoded"}
        )
        print(f"Signup response: {response.status_code} - {response.text}")  # 디버깅용 로그
        return response.json()
    except Exception as e:
        print(f"Signup error: {str(e)}")  # 디버깅용 로그
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/auth/users/me")
async def get_current_user(token: str):
    try:
        response = await http_client.get(
            f"{AUTH_SERVICE_URL}/auth/users/me",
            headers={"Authorization": f"Bearer {token}"}
        )
        return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 프로필 서비스 라우팅
@app.get("/api/profile/{character}")
async def get_profile(character: str):
    try:
        print(f"Profile request for: {character}")  # 디버깅용 로그
        response = await http_client.get(
            f"{PROFILE_SERVICE_URL}/{character}"  # /api/profile/ 제거
        )
        print(f"Profile response: {response.status_code} - {response.text}")  # 디버깅용 로그
        return response.json()
    except Exception as e:
        print(f"Profile error: {str(e)}")  # 디버깅용 로그
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000) 