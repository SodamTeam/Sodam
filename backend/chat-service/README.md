# Sodam Chat-Service

Sodam 모바일 앱의 ‘대화/콘텐츠 생성’ 마이크로서비스입니다.  
FastAPI + SQLite 기반으로 ▶ AI 챗 응답 스트리밍 ▸ 대화 기록 저장 ▸ Google Books 추천을 담당합니다.

![FastAPI](https://img.shields.io/badge/FastAPI-0.111.0-009688?logo=fastapi&logoColor=white)
![Python](https://img.shields.io/badge/python-3.11-blue)
![License](https://img.shields.io/badge/license-MIT-green)

---

## 주요 기능
| 엔드포인트 | 메서드 | 설명 |
|------------|--------|------|
| `/api/chat/generate` | POST | Ollama LLM 호출 / SSE 스트리밍 지원 |
| `/generate` | POST | 위와 동일한 별칭(Alias) |
| `/chat` | POST | 사용자의 메시지를 저장하고 LLM 응답 반환 |
| `/chat/history/{user_id}` | GET | 특정 사용자의 채팅 기록 조회 |
| `/generate-response` | POST | 캐릭터 프로필을 반영한 즉답 |
| `/api/chat/message` | POST | 메시지 저장용 스텁 |
| `/api/chat/generate?mode=book` | POST | Google Books API로 책 3권 추천 |

* Ollama(기본 모델 `gemma3:4b`) 프록시  
* Google Books 연동 — 검색어 기반 도서 추천  
* 채팅·응답을 SQLite(`chat.db`)에 저장  
* 전역 CORS 허용

---

## 기술 스택
| Layer | Tech |
|-------|------|
| Backend | FastAPI, Uvicorn |
| LLM Proxy | Ollama |
| DB | SQLAlchemy 2 + SQLite |
| 외부 API | Google Books |

---

## 실행 방법

```bash
# 1) 의존성
python -m venv .venv && source .venv/bin/activate   # Windows: .\.venv\Scripts\activate
pip install -r requirements.txt

# 2) DB 초기화(최초 1회)
python - <<'PY'
from database import Base, engine
import models
Base.metadata.create_all(bind=engine)
PY

# 3) 서버 실행
uvicorn main:app --reload --port 8001
# Swagger: http://localhost:8001/docs
````

---

## 프로젝트 구조

```text
chat-service/
├── app.py          # FastAPI 엔트리포인트
├── database.py     # DB 세션 · 엔진
├── models.py       # Chat 테이블
├── schemas.py      # Pydantic 스키마
├── requirements.txt
└── chat.db         # SQLite (런타임 생성)
```

---

## 환경 변수

| 변수                 | 기본값                               | 설명                 |
| ------------------ | --------------------------------- | ------------------ |
| `OLLAMA_API_URL`   | `http://localhost:11434/api/chat` | Ollama HTTP 엔드포인트  |
| `DEFAULT_MODEL`    | `gemma3:4b`                       | 기본 모델 태그           |
| `API_GATEWAY_URL`  | `http://localhost:8000`           | 프로필·Auth 서비스 게이트웨이 |
| `GOOGLE_BOOKS_API` | *(고정)*                            | Google Books URL   |
