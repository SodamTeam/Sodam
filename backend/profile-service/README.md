# 🖼️ Sodam Profile-Service

Sodam 캐릭터들의 **프로필(성격·관심사·이미지 등)** 을 저장·제공하는 마이크로서비스입니다.  
챗봇 인격 설정에 이용되며, Gateway → Chat-Service 에서 호출해 AI 시스템 프롬프트를 구성합니다.

![FastAPI](https://img.shields.io/badge/FastAPI-0.111.0-009688?logo=fastapi&logoColor=white)
![Python](https://img.shields.io/badge/python-3.11-blue)
![License](https://img.shields.io/badge/license-MIT-green)

---

## ✨ 주요 엔드포인트
| Path | Method | 설명 |
|------|--------|------|
| `/api/profile/{username}` | **GET** | 캐릭터 프로필 조회 *(초기 4종: harin·sera·yuri·mina)* |
| `/api/profile/{username}` | **PUT** | 프로필 갱신 |
| `/{username}` | **POST** | 새 프로필 생성(내부용) |

* 애플리케이션 시작 시 **초기 프로필 4건**(문학·테크·과학·힐링 소녀) 자동 삽입  
* FastAPI + SQLAlchemy + SQLite(`profile.db`)  
* 전역 CORS 허용

---

## 🛠️ 기술 스택
| Layer | Tech |
|-------|------|
| Backend | FastAPI, Uvicorn |
| ORM/DB | SQLAlchemy + SQLite |
| Container | Docker (python:3.11-slim) |

---

## 🚀 빠른 시작

```bash
# 1) 의존성 설치
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

## 🐳 Docker 사용

```bash
docker build -t sodam-profile:latest .
docker run -d -p 8003:8003 --name sodam-profile \
  -v "$PWD/profile.db:/app/profile.db" \
  sodam-profile:latest
```

---

## 📂 프로젝트 구조

```text
profile-service/
├── app.py          # FastAPI 엔트리포인트
├── database.py     # DB 세션 · 엔진
├── models.py       # Profile 테이블
├── schemas.py      # Pydantic 스키마
├── Dockerfile
├── requirements.txt
└── profile.db      # SQLite (런타임 생성)
```

---

## 🔧 환경 변수(선택)

| 변수             | 기본값                      | 설명                  |
| -------------- | ------------------------ | ------------------- |
| `DATABASE_URL` | `sqlite:///./profile.db` | 다른 RDBMS 사용 시 오버라이드 |
| `PORT`         | 8003                     | Uvicorn 포트 변경 시     |

---

## 📜 라이선스

MIT © 2025 Sodam Team

```
```
