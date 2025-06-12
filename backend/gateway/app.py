# backend/gateway/app.py

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
CHAT_HISTORY_SERVICE_URL = "http://localhost:8004" 


# HTTP 클라이언트 설정
http_client = httpx.AsyncClient(timeout=30.0)

# 채팅 서비스 라우팅
@app.post("/api/chat/generate")
async def handle_chat_generate(request: Request):
    try:
        request_data = await request.json()
        is_stream = request_data.get("stream", False)

        if is_stream:
            async def stream_response():
                try:
                    async with httpx.AsyncClient() as client:
                        async with client.stream(
                            'POST',
                            f"{CHAT_SERVICE_URL}/api/chat/generate", #올바른 엔드포인트
                            json=request_data,
                            timeout=30.0
                        ) as response:
                            if response.status_code != 200:
                                error_text = await response.text()
                                yield f"data: {json.dumps({'error': error_text})}\n\n"
                                return
                            async for chunk in response.aiter_bytes():
                                yield chunk
                except Exception as e:
                    yield f"data: {json.dumps({'error': str(e)})}\n\n"

            return StreamingResponse(
                stream_response(),
                media_type="text/event-stream"
            )
        else:
            # 비스트리밍 요청 처리
            response = await http_client.post(
                f"{CHAT_SERVICE_URL}/api/chat/generate", # chat-service의 올바른 엔드포인트
                json=request_data
            )
            response.raise_for_status()
            return response.json()

    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=str(e.response.text))
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

@app.get("/api/chat/history/{user_id}/{room}")
async def get_chat_history(user_id: int, room: str):
    response = await http_client.get(
        f"{CHAT_HISTORY_SERVICE_URL}/history/{user_id}/{room}",
        timeout=30.0,
    )
    response.raise_for_status()
    return response.json()

@app.post("/api/chat/history")
async def create_chat_history(entry: dict):
    """{ "user_id": int, "sender": "user"|"bot", "content": str } 을 저장"""
    response = await http_client.post (
        f"{CHAT_HISTORY_SERVICE_URL}/history/",
        json=entry,
        timeout=30.0,
    )
    response.raise_for_status()
    return JSONResponse(
        status_code=response.status_code,
        content=response.json()
    )


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
        return JSONResponse(
            status_code=response.status_code,
            content=response.json()
        )
    except Exception as e:
        print(f"Login error: {str(e)}")  # 디버깅용 로그
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/auth/signup")
async def signup(request: Request):
    try:
        request_data = await request.json()
        print(f"Signup request data: {request_data}")  # 디버깅용 로그
        response = await http_client.post(
            f"{AUTH_SERVICE_URL}/signup",
            json=request_data,
            headers={"Content-Type": "application/json"}
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
            f"{PROFILE_SERVICE_URL}/api/profile/{character}"  # /api/profile/ 추가
        )
        print(f"Profile response: {response.status_code} - {response.text}")  # 디버깅용 로그
        return response.json()
    except Exception as e:
        print(f"Profile error: {str(e)}")  # 디버깅용 로그
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000) 