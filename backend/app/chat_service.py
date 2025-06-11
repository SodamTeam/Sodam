# chat_service.py
import httpx
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import os

router = APIRouter()

class GenerateRequest(BaseModel):
    model: str
    prompt: str | None = None
    mode: str  # 'novel', 'analyze', 'poem', 'book'
    stream: bool = False
    system: str | None = None

class GenerateResponse(BaseModel):
    response: str

LLM_SERVICE_URL = os.getenv("LLM_SERVICE_URL", "http://localhost:11434/api/generate")
GOOGLE_BOOKS_API = "https://www.googleapis.com/books/v1/volumes"

@router.post("", response_model=GenerateResponse)
async def generate(req: GenerateRequest):
    try:
        # 'book' 모드일 경우 Google Books API 사용
        if req.mode == "book":
            if not req.prompt:
                raise HTTPException(status_code=400, detail="책 키워드를 입력해주세요.")

            async with httpx.AsyncClient() as client:
                params = {
                    "q": req.prompt,
                    "maxResults": 3,
                    "printType": "books",
                    "langRestrict": "ko"
                }
                resp = await client.get(GOOGLE_BOOKS_API, params=params)
                if resp.status_code != 200:
                    raise HTTPException(status_code=resp.status_code, detail="Google Books API 오류")

                data = resp.json()
                books = data.get("items", [])
                if not books:
                    return GenerateResponse(response="추천할 책이 없습니다.")

                results = []
                for book in books:
                    info = book["volumeInfo"]
                    title = info.get("title", "제목 없음")
                    authors = ", ".join(info.get("authors", []))
                    desc = info.get("description", "설명이 없습니다.")
                    results.append(f"\U0001F4DA 제목: {title}\n\U0001F464 저자: {authors}\n\U0001F4DD 소개: {desc[:100]}...\n")

                return GenerateResponse(response="\n\n".join(results))

        # 'book' 이외 모드일 경우 LLM API 호출
        payload: dict = {
            "model": req.model,
            "prompt": req.prompt or "기본 프롬프트",
            "stream": req.stream,
        }
        if req.system:
            payload["system"] = req.system

        async with httpx.AsyncClient(timeout=60.0) as client:
            resp = await client.post(LLM_SERVICE_URL, json=payload)
            resp.raise_for_status()
            data = resp.json()

        result = data.get("response")
        if not result:
            raise HTTPException(status_code=500, detail="LLM 응답이 비어 있어요.")

        return GenerateResponse(response=result)

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"서버 오류: {e}")
