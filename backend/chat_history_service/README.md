# Chat History Service

Sodam 앱의 대화 로그 저장/조회 마이크로서비스입니다.  
FastAPI + SQLite로 채팅 내용을 영구 저장하고, 사용자·대화방(room) 기준으로 가져올 수 있습니다.

![FastAPI](https://img.shields.io/badge/FastAPI-0.111.0-009688?logo=fastapi&logoColor=white)
![Python](https://img.shields.io/badge/python-3.11-blue)
![License](https://img.shields.io/badge/license-MIT-green)

---

## 주요 엔드포인트
| Path | Method | 설명 |
|------|--------|------|
| `/history/` | POST | 채팅 1건 저장 |
| `/history/{user_id}/{room}` | GET | 특정 사용자 + 방의 대화 내역 조회 (오래된 순) |

* `user_id`, `sender`, `content`, `room`, `timestamp` 필드 보존  
* ORM : SQLAlchemy 2  
* DB : SQLite(`history.db`) – 컨테이너 볼륨 마운트 가능

---

## 기술 스택
| Layer | Tech |
|-------|------|
| Backend | FastAPI, Uvicorn |
| DB | SQLAlchemy + SQLite |

---

## 실행 방법

```bash
# 1) 의존성
python -m venv .venv && source .venv/bin/activate   # Win: .\.venv\Scripts\activate
pip install -r requirements.txt

# 2) DB 초기화(최초 1회)
python - <<'PY'
from database import Base, engine
import models
Base.metadata.create_all(bind=engine)
PY

# 3) 서버 실행
uvicorn app:app --reload --port 8003
# Swagger: http://localhost:8003/docs
````

---

## 프로젝트 구조

```text
chat_history_service/
├── app.py          # FastAPI 엔트리포인트
├── database.py     # DB 세션·엔진
├── models.py       # ChatHistory 테이블
├── schemas.py      # Pydantic 스키마
├── requirements.txt
└── history.db      # SQLite(런타임 생성)
```

---

## 환경 변수(선택)

| 변수             | 기본값                      | 설명                  |
| -------------- | ------------------------ | ------------------- |
| `DATABASE_URL` | `sqlite:///./history.db` | 다른 RDBMS 사용 시 오버라이드 |
| `PORT`         | 8003                     | Uvicorn 포트 변경 시     |
