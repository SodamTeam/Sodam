# backend/gateway/app.py

from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response
import httpx

app = FastAPI(title="Sodam API Gateway")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

DIARY_SERVICE_URL = "http://localhost:8005"

async def proxy_request(method: str, url: str, **kwargs):
    async with httpx.AsyncClient() as client:
        resp = await client.request(method, url, **kwargs)
        if resp.status_code >= 400:
            raise HTTPException(resp.status_code, resp.text)
        return Response(content=resp.content, status_code=resp.status_code, media_type=resp.headers.get("content-type"))

@app.post("/api/diary/upload-image/")
async def proxy_upload(request: Request):
    # file 업로드는 multipart 여서, Flutter 쪽 그대로 Gateway→Service로 전송하도록 구현 필요
    return await proxy_request("POST", f"{DIARY_SERVICE_URL}/api/diary/upload-image/", data=await request.body(), headers=request.headers)

@app.post("/api/diary/")
async def proxy_create(request: Request):
    return await proxy_request("POST", f"{DIARY_SERVICE_URL}/api/diary/", json=await request.json())

@app.get("/api/diary/")
async def proxy_list():
    return await proxy_request("GET", f"{DIARY_SERVICE_URL}/api/diary/")

@app.put("/api/diary/{id}")
async def proxy_update(id: int, request: Request):
    return await proxy_request("PUT", f"{DIARY_SERVICE_URL}/api/diary/{id}", json=await request.json())

@app.delete("/api/diary/{id}")
async def proxy_delete(id: int):
    return await proxy_request("DELETE", f"{DIARY_SERVICE_URL}/api/diary/{id}")

@app.get("/health")
async def health():
    return {"status": "gateway OK"}
