from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

router = APIRouter()

class GenerateRequest(BaseModel):
    model: str
    prompt: str
    stream: bool = False
    system: str | None = None

class GenerateResponse(BaseModel):
    response: str

@router.post("", response_model=GenerateResponse)
async def generate(req: GenerateRequest):
    try:
        # TODO: 실제 LLM 호출 로직으로 교체
        result = f"모델 {req.model} 에서 생성한 응답: '{req.prompt}'"
        return GenerateResponse(response=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"AI 서버 오류: {e}")
