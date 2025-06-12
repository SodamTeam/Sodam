import httpx
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import os
from fastapi.responses import JSONResponse, Response
from typing import Optional

# 상수 정의
LLM_SERVICE_URL = os.getenv("LLM_SERVICE_URL", "http://localhost:11434/api/generate")
DEFAULT_MODEL = os.getenv("DEFAULT_MODEL", "gemma3:4b")
GOOGLE_BOOKS_API = "https://www.googleapis.com/books/v1/volumes"
MAX_BOOK_RESULTS = 3
BOOK_DESC_LENGTH = 100

router = APIRouter()

class GenerateRequest(BaseModel):
    model: str
    prompt: Optional[str] = None
    mode: str  # 'novel', 'analyze', 'poem', 'book'
    stream: bool = False
    system: Optional[str] = None

class GenerateResponse(BaseModel):
    response: str

async def fetch_google_books(prompt: str) -> list:
    """Google Books API를 호출하여 책 정보를 가져옵니다."""
    async with httpx.AsyncClient() as client:
        params = {
            "q": prompt,
            "maxResults": MAX_BOOK_RESULTS,
            "printType": "books",
            "langRestrict": "ko"
        }
        resp = await client.get(GOOGLE_BOOKS_API, params=params)
        if resp.status_code != 200:
            raise HTTPException(status_code=resp.status_code, detail="Google Books API 오류")
        return resp.json().get("items", [])

def format_book_info(book: dict) -> str:
    """책 정보를 포맷팅합니다."""
    info = book["volumeInfo"]
    title = info.get("title", "제목 없음")
    authors = ", ".join(info.get("authors", []))
    desc = info.get("description", "설명이 없습니다.")
    return f"📚 제목: {title}\n👤 저자: {authors}\n📝 소개: {desc[:BOOK_DESC_LENGTH]}...\n"

async def call_llm_service(payload: dict) -> str:
    """LLM 서비스를 호출합니다."""
    async with httpx.AsyncClient(timeout=60.0) as client:
        resp = await client.post(LLM_SERVICE_URL, json=payload)
        try:
            data = resp.json()
            return data.get("response", resp.text)
        except Exception:
            return resp.text

@router.post("")
async def generate(req: GenerateRequest):
    """
    POST /api/generate
    body: {
      prompt: str,
      system?: str
    }
    """
    try:
        if req.mode == "book":
            if not req.prompt:
                raise HTTPException(status_code=400, detail="책 키워드를 입력해주세요.")
            
            books = await fetch_google_books(req.prompt)
            if not books:
                return JSONResponse(
                    content={"response": "추천할 책이 없습니다."},
                    media_type="application/json"
                )

            results = [format_book_info(book) for book in books]
            return JSONResponse(
                content={"response": "\n\n".join(results)},
                media_type="application/json"
            )
        
        # LLM 서비스 호출
        payload = {
            "model": req.model or DEFAULT_MODEL,
            "prompt": req.prompt,
            "stream": req.stream,
        }
        if req.system:
            payload["system"] = req.system

        result = await call_llm_service(payload)
        if not result:
            return JSONResponse(
                content={"response": "응답을 이해하지 못했어요."},
                media_type="application/json"
            )
        
        return JSONResponse(
            content={"response": result},
            media_type="application/json"
        )

    except httpx.HTTPError as e:
        # LLM 서비스 호출에 실패했을 때
        raise HTTPException(status_code=502, detail=f"AI 연결 실패: {str(e)}")
    except Exception as e:
        # 기타 예외 상황
        raise HTTPException(status_code=500, detail=f"서버 오류: {str(e)}")
