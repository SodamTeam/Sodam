# Auth-Service

Sodam 프로젝트의 인증·권한(Identity) 마이크로서비스입니다.  
FastAPI + JWT + SQLite 로 회원가입, 로그인, 토큰 발급/검증을 처리합니다.

![FastAPI](https://img.shields.io/badge/FastAPI-0.111.0-009688?logo=fastapi&logoColor=white)
![Python](https://img.shields.io/badge/python-3.11-blue)
![License](https://img.shields.io/badge/license-MIT-green)

---

##  주요 엔드포인트
| Path | Method | 설명 |
|------|--------|------|
| `/register` | POST | 이메일 기반 회원가입 |
| `/signup` | POST | ID(사용자명) 기반 회원가입 |
| `/token` | POST | 이메일+비밀번호 로그인 → JWT 발급 |
| `/login` | POST | ID+비밀번호 로그인 → JWT 발급 |
| `/users/me` | GET  | Bearer 토큰 검증 후 내 정보 반환 |

* Bcrypt 비밀번호 해싱  
* HS256 JWT (기본 만료 30분)  
* OAuth2PasswordBearer 스키마 사용  
* SQLAlchemy ORM + SQLite (`auth.db`)  

---

##  기술 스택
| Layer | Tech |
|-------|------|
| Backend | FastAPI, Uvicorn |
| Auth | OAuth2, PyJWT (jose) |
| Hashing | Passlib(bcrypt) |
| DB | SQLAlchemy 2 + SQLite |

---

##  실행 방법

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
uvicorn main:app --reload --port 8002
# Swagger: http://localhost:8002/docs
````

---

##  프로젝트 구조

```text
auth-service/
├── app.py          # FastAPI 엔트리포인트
├── database.py     # DB 세션 · 엔진
├── models.py       # User 테이블
├── schemas.py      # Pydantic 스키마
├── requirements.txt
└── auth.db         # SQLite (런타임 생성)
```

---

##  환경 변수

| 변수                            | 기본값                   | 설명                        |
| ----------------------------- | --------------------- | ------------------------- |
| `SECRET_KEY`                  | `your-secret-key`     | JWT 서명 키 (필수, 반드시 변경) |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | 30                    | 토큰 유효기간(분)                |
| `DATABASE_URL`                | `sqlite:///./auth.db` | SQLite 경로 또는 다른 RDB URL   |

```
```
