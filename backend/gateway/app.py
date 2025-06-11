from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
import httpx
from fastapi.responses import JSONResponse, Response
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="Sodam API Gateway")

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# 서비스 URL 설정
SERVICE_URLS = {
    "auth": os.getenv("AUTH_SERVICE_URL", "http://localhost:8001"),
    "chat": os.getenv("CHAT_SERVICE_URL", "http://localhost:8002"),
    "history": os.getenv("HISTORY_SERVICE_URL", "http://localhost:8003"),
    "profile": os.getenv("PROFILE_SERVICE_URL", "http://localhost:8004"),
}

async def proxy_request(service: str, request: Request):
    if service not in SERVICE_URLS:
        raise HTTPException(status_code=404, detail="Service not found")
    
    url = f"{SERVICE_URLS[service]}{request.url.path}"
    
    async with httpx.AsyncClient() as client:
        try:
            response = await client.request(
                method=request.method,
                url=url,
                headers=dict(request.headers),
                params=dict(request.query_params),
                content=await request.body()
            )
            return Response(
                content=response.content,
                status_code=response.status_code,
                headers=dict(response.headers)
            )
        except httpx.RequestError as e:
            raise HTTPException(status_code=503, detail=str(e))

# Auth Service Routes
@app.api_route("/auth/{path:path}", methods=["GET", "POST", "PUT", "DELETE"])
async def auth_service(request: Request, path: str):
    return await proxy_request("auth", request)

# Chat Service Routes
@app.api_route("/chat/{path:path}", methods=["GET", "POST", "PUT", "DELETE"])
async def chat_service(request: Request, path: str):
    return await proxy_request("chat", request)

# History Service Routes
@app.api_route("/history/{path:path}", methods=["GET", "POST", "PUT", "DELETE"])
async def history_service(request: Request, path: str):
    return await proxy_request("history", request)

# Profile Service Routes
@app.api_route("/profile/{path:path}", methods=["GET", "POST", "PUT", "DELETE"])
async def profile_service(request: Request, path: str):
    return await proxy_request("profile", request)

@app.get("/health")
async def health_check():
    return {"status": "ok"} 