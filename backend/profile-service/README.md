````markdown
# 🖼️ Sodam Profile-Service

Sodam 캐릭터들의 프로필(이름·성격·관심사·이미지)을 저장·제공하는 마이크로서비스입니다.  
Gateway → Chat-Service 호출 시 프로필 데이터를 읽어 AI 프롬프트를 만들 때 사용됩니다.

![FastAPI](https://img.shields.io/badge/FastAPI-0.111.0-009688?logo=fastapi&logoColor=white)
![Python](https://img.shields.io/badge/python-3.11-blue)
![License](https://img.shields.io/badge/license-MIT-green)

---

## 주요 엔드포인트
| Path | Method | 설명 |
|------|--------|------|
| `/api/profile/{username}` | **GET** | 프로필 조회&nbsp;(초기: **harin**, **sera**, **yuri**, **mina**) |
| `/api/profile/{username}` | **PUT** | 프로필 수정 |
| `/{username}` | **POST** | 새 프로필 추가&nbsp;(내부용) |

* 서버 기동 시 기본 프로필 4개 자동 삽입  
* FastAPI + SQLAlchemy + SQLite(`profile.db`)  
* CORS 전체 허용

---

## 기술 스택
| Layer | Tech |
|-------|------|
| Backend | FastAPI, Uvicorn |
| ORM/DB  | SQLAlchemy + SQLite |

---

## 실행 방법

```bash
# 1) 가상 환경
python -m venv .venv
source .venv/bin/activate          # Windows: .\.venv\Scripts\activate

# 2) 의존성 설치
pip install -r requirements.txt

# 3) DB 스키마 생성(최초 1회)
python - <<'PY'
from database import Base, engine
import models
Base.metadata.create_all(bind=engine)
PY

# 4) 서버 실행
uvicorn app:app --reload --port 8003
# Swagger: http://localhost:8003/docs
````

---

## 프로젝트 구조

```text
profile-service/
├── app.py          # FastAPI 엔트리포인트
├── database.py     # 세션·엔진
├── models.py       # Profile 모델
├── schemas.py      # Pydantic 스키마
├── requirements.txt
└── profile.db      # SQLite (런타임 생성)
```

---

## 환경 변수

| 변수             | 기본값                      | 설명                  |
| -------------- | ------------------------ | ------------------- |
| `DATABASE_URL` | `sqlite:///./profile.db` | 다른 RDBMS 사용 시 경로 변경 |
| `PORT`         | 8003                     | Uvicorn 실행 포트       |


