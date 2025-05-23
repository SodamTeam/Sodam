from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import httpx
import os

router = APIRouter()

class GenerateRequest(BaseModel):
    model: str
    prompt: str
    stream: bool = False
    system: str | None = None

class GenerateResponse(BaseModel):
    response: str

# LLM 서비스 URL (환경변수로도 설정 가능)
LLM_SERVICE_URL = os.getenv("LLM_SERVICE_URL", "http://localhost:11434/api/generate")

@router.post("", response_model=GenerateResponse)
async def generate(req: GenerateRequest):
    """
    POST /api/generate
    body: {
      model: str,
      prompt: str,
      stream: bool,
      system?: str
    }
    """
    payload: dict = {
        "model": req.model,
        "prompt": req.prompt,
        "stream": req.stream,
    }
    if req.system:
        payload["system"] = req.system

    try:
        async with httpx.AsyncClient(timeout=60.0) as client:
            resp = await client.post(LLM_SERVICE_URL, json=payload)
            resp.raise_for_status()
            data = resp.json()
    except httpx.HTTPError as e:
        # LLM 서비스 호출에 실패했을 때
        raise HTTPException(status_code=502, detail=f"LLM 호출 오류: {e}")

    # LLM 서비스가 반환한 응답 구조에 맞춰서 처리
    result = data.get("response")
    if not result:
        raise HTTPException(status_code=500, detail="LLM 응답이 비어 있어요.")
    return GenerateResponse(response=result)
