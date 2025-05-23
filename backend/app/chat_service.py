from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import httpx
import os

router = APIRouter()

class GenerateRequest(BaseModel):
    prompt: str
    system: str | None = None

class GenerateResponse(BaseModel):
    response: str

# LLM 서비스 URL (환경변수로도 설정 가능)
LLM_SERVICE_URL = os.getenv("LLM_SERVICE_URL", "http://localhost:11434/api/generate")
DEFAULT_MODEL = os.getenv("DEFAULT_MODEL", "gemma3:4b")

@router.post("", response_model=GenerateResponse)
async def generate(req: GenerateRequest):
    """
    POST /api/generate
    body: {
      prompt: str,
      system?: str
    }
    """
    payload: dict = {
        "model": DEFAULT_MODEL,
        "prompt": req.prompt,
        "stream": False,
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
        raise HTTPException(status_code=502, detail=f"AI 연결 실패: {str(e)}")
    except Exception as e:
        # 기타 예외 상황
        raise HTTPException(status_code=500, detail=f"AI 서버 오류: {str(e)}")

    # LLM 서비스가 반환한 응답 구조에 맞춰서 처리
    result = data.get("response")
    if not result:
        return GenerateResponse(response="응답을 이해하지 못했어요.")
    return GenerateResponse(response=result)
