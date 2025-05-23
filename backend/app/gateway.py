# backend/app/gateway.py
from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
import httpx

app = FastAPI(title="SODAM API Gateway")

# 개발 단계용 CORS 전역 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# 각 서비스 베이스 URL (Docker Compose 등에서 서비스 이름으로 호출 가능)
SERVICE_URLS = {
    "chat":   "http://localhost:8001",
    "profile":"http://localhost:8002",
    "auth":   "http://localhost:8003",
    "image":  "http://localhost:8004",
    "music":  "http://localhost:8005",
    "diary":  "http://localhost:8006",
}

# 공통 유틸: downstream 호출
async def proxy_request(method: str, url: str, **kwargs):
    async with httpx.AsyncClient() as client:
        resp = await client.request(method, url, **kwargs)
        if resp.status_code >= 400:
            raise HTTPException(status_code=resp.status_code, detail=resp.text)
        return resp.json()

# 1) 로그인 요청 → Auth Service
@app.post("/api/auth/login")
async def login(request: Request):
    body = await request.json()
    return await proxy_request(
        "POST",
        f"{SERVICE_URLS['auth']}/login",
        json=body,
    )

# 2) 캐릭터 선택 → Profile Service
@app.post("/api/profile/select")
async def select_profile(request: Request):
    token = request.headers.get("authorization")
    body = await request.json()
    return await proxy_request(
        "POST",
        f"{SERVICE_URLS['profile']}/select",
        headers={"Authorization": token} if token else {},
        json=body,
    )

# 3) 채팅 메시지 생성 → Chat Service
@app.post("/api/chat/generate")
async def chat_generate(request: Request):
    token = request.headers.get("authorization")
    body = await request.json()
    return await proxy_request(
        "POST",
        f"{SERVICE_URLS['chat']}/api/generate",
        headers={"Authorization": token} if token else {},
        json=body,
    )

# 4) 이미지 생성 → Image Gen Service
@app.post("/api/image/generate")
async def image_generate(request: Request):
    token = request.headers.get("authorization")
    body = await request.json()
    return await proxy_request(
        "POST",
        f"{SERVICE_URLS['image']}/api/generate",
        headers={"Authorization": token} if token else {},
        json=body,
    )

# 5) 음악 생성 → Music Gen Service
@app.post("/api/music/generate")
async def music_generate(request: Request):
    token = request.headers.get("authorization")
    body = await request.json()
    return await proxy_request(
        "POST",
        f"{SERVICE_URLS['music']}/api/generate",
        headers={"Authorization": token} if token else {},
        json=body,
    )

# 6) 감정 일기 작성 → Diary Service
@app.post("/api/diary/write")
async def diary_write(request: Request):
    token = request.headers.get("authorization")
    body = await request.json()
    return await proxy_request(
        "POST",
        f"{SERVICE_URLS['diary']}/write",
        headers={"Authorization": token} if token else {},
        json=body,
    )

# 감정 일기 조회
@app.get("/api/diary/list")
async def diary_list(request: Request):
    token = request.headers.get("authorization")
    return await proxy_request(
        "GET",
        f"{SERVICE_URLS['diary']}/list",
        headers={"Authorization": token} if token else {},
    )

# 헬스체크
@app.get("/health")
async def health():
    return {"status": "gateway OK"}
