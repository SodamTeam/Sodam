import httpx
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

router = APIRouter()

class GenerateRequest(BaseModel):
    model: str
    prompt: str | None = None  # 사용자가 입력한 책 이름이나 키워드
    mode: str  # 'novel', 'analyze', 'poem', 'book'
    stream: bool = False
    system: str | None = None

class GenerateResponse(BaseModel):
    response: str

GOOGLE_BOOKS_API = "https://www.googleapis.com/books/v1/volumes"

@router.post("", response_model=GenerateResponse)
async def generate(req: GenerateRequest):
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
                    return GenerateResponse(response="추천할 책이 없습니다.")

                results = []
                for book in books:
                    info = book["volumeInfo"]
                    title = info.get("title", "제목 없음")
                    authors = ", ".join(info.get("authors", []))
                    desc = info.get("description", "설명이 없습니다.")
                    results.append(f"📚 제목: {title}\n👤 저자: {authors}\n📝 소개: {desc[:100]}...\n")

                return GenerateResponse(response="\n\n".join(results))
        
        # GPT 응답 처리 (기존 로직)
        else:
            final_prompt = req.prompt or "기본 프롬프트"
            result = f"모드 '{req.mode}'에 따라 생성한 응답: '{final_prompt}'"
            return GenerateResponse(response=result)

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"서버 오류: {e}")
