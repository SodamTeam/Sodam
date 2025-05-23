import httpx
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import httpx
import os
from fastapi.responses import JSONResponse

router = APIRouter()

class GenerateRequest(BaseModel):
    model: str
    prompt: str | None = None  # 사용자가 입력한 책 이름이나 키워드
    mode: str  # 'novel', 'analyze', 'poem', 'book'
    stream: bool = False
    system: str | None = None

class GenerateResponse(BaseModel):
    response: str

# LLM 서비스 URL (환경변수로도 설정 가능)
LLM_SERVICE_URL = os.getenv("LLM_SERVICE_URL", "http://localhost:11434/api/generate")
DEFAULT_MODEL = os.getenv("DEFAULT_MODEL", "gemma3:4b")

GOOGLE_BOOKS_API = "https://www.googleapis.com/books/v1/volumes"

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
            
            # Google Books API 호출
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
                    return JSONResponse(
                        content={"response": "추천할 책이 없습니다."},
                        media_type="application/json; charset=utf-8"
                    )

                results = []
                for book in books:
                    info = book["volumeInfo"]
                    title = info.get("title", "제목 없음")
                    authors = ", ".join(info.get("authors", []))
                    desc = info.get("description", "설명이 없습니다.")
                    results.append(f"📚 제목: {title}\n👤 저자: {authors}\n📝 소개: {desc[:100]}...\n")

                return JSONResponse(
                    content={"response": "\n\n".join(results)},
                    media_type="application/json; charset=utf-8"
                )
        
        # LLM 서비스 호출
        payload = {
            "model": req.model or DEFAULT_MODEL,
            "prompt": req.prompt,
            "stream": req.stream,
        }
        if req.system:
            payload["system"] = req.system

        async with httpx.AsyncClient(timeout=60.0) as client:
            resp = await client.post(LLM_SERVICE_URL, json=payload)
            resp.encoding = 'utf-8'
            data = resp.json()

        result = data.get("response")
        if not result:
            return JSONResponse(
                content={"response": "응답을 이해하지 못했어요."},
                media_type="application/json; charset=utf-8"
            )
        return JSONResponse(
            content={"response": result},
            media_type="application/json; charset=utf-8"
        )

    except httpx.HTTPError as e:
        # LLM 서비스 호출에 실패했을 때
        raise HTTPException(status_code=502, detail=f"AI 연결 실패: {str(e)}")
    except Exception as e:
        # 기타 예외 상황
        raise HTTPException(status_code=500, detail=f"서버 오류: {str(e)}")
