# 🔐 Sodam Auth-Service

**Sodam** 프로젝트의 인증/권한 분리형 마이크로서비스입니다.  
FastAPI + JWT + SQLite 기반으로 회원가입·로그인·토큰 검증 기능을 제공합니다.

![fastapi](https://img.shields.io/badge/FastAPI-0.111.0-009688?logo=fastapi&logoColor=white)
![python](https://img.shields.io/badge/python-3.11-blue)
![license](https://img.shields.io/badge/license-MIT-green)

---

## ✨ 주요 기능
| 엔드포인트 | 메서드 | 설명 |
|------------|--------|------|
| `/register` | POST | **이메일 기반** 회원 가입 |
| `/signup` | POST | **아이디(ID)** 기반 회원 가입 |
| `/token` | POST | 이메일·비밀번호 로그인 → **JWT 반환** |
| `/login` | POST | ID·비밀번호 로그인 → **JWT 반환** |
| `/users/me` | GET  | JWT 검증 후 내 정보 조회 |

* Bcrypt 비밀번호 해싱  
* HS256 서명으로 Access Token 발급 (기본 30분 만료)  
* SQLAlchemy ORM + SQLite 로컬 DB  
* Docker 이미지 (포트 `8002`) 지원

---

## 🛠️ 기술 스택
| Layer        | Tech |
|--------------|------|
| **백엔드**   | FastAPI, Uvicorn, Pydantic |
| **ORM/DB**   | SQLAlchemy 2, SQLite |
| **Auth**     | OAuth2PasswordBearer, PyJWT (Jose) |
| **해싱**     | Passlib (bcrypt) |
| **컨테이너** | Docker, python:3.11-slim |

---

## 🚀 빠른 시작 (로컬)

```bash
# 1) 가상환경 & 의존성
python -m venv .venv
source .venv/bin/activate          # Windows = .venv\Scripts\activate
pip install -r requirements.txt

# 2) 데이터베이스 초기화 (첫 실행 시)
python - <<'PY'
from database import Base, engine
import models
Base.metadata.create_all(bind=engine)
PY

# 3) 서버 실행
uvicorn main:app --reload --port 8002
