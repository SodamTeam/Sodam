# 🌐 Sodam API-Gateway

Sodam 백엔드 마이크로서비스들을 하나의 엔드포인트(`/api/*`)로 묶어주는 **BFF(Backend-for-Frontend)** 게이트웨이입니다.  
FastAPI + httpx 스트리밍 프록시를 사용해 **Chat / Auth / Profile / History** 서비스 호출을 대행하고 CORS 설정을 일원화합니다.

![FastAPI](https://img.shields.io/badge/FastAPI-0.111.0-009688?logo=fastapi&logoColor=white)
![Python](https://img.shields.io/badge/python-3.11-blue)
![License](https://img.shields.io/badge/license-MIT-green)

---

## 🗺️ 라우팅 테이블

| Gateway Endpoint | 내부 서비스 | Target URL |
|------------------|-------------|------------|
| `POST /api/chat/generate` | **chat-service** | `http://localhost:8001/api/chat/generate` |
| `POST /api/chat` | chat-service | `…/chat` |
| `GET  /api/chat/history/{user_id}/{room}` | chat-history-service | `http://localhost:8004/history/{user_id}/{room}` |
| `POST /api/chat/history` | chat-history-service | `…/history/` |
| `POST /api/auth/login` | auth-service | `http://localhost:8002/login` |
| `POST /api/auth/signup` | auth-service | `…/signup` |
| `GET  /api/auth/users/me` | auth-service | `…/auth/users/me` |
| `GET  /api/profile/{character}` | profile-service | `http://localhost:8003/api/profile/{character}` |

* `/api/chat/generate` 는 **SSE 스트리밍** 지원 — 클라이언트에 그대로 전달  
* 전역 **CORS 허용**  
* 모든 서브서비스 타임아웃 30 초

---

## 🛠️ 기술 스택
| Layer | Tech |
|-------|------|
| Framework | FastAPI |
| Async HTTP | httpx 0.27 |
| Runtime | Uvicorn |
| Container | Docker (python:3.11-slim) |

---

## 🚀 빠른 시작

```bash
python -m venv .venv && source .venv/bin/activate   # Win: .\.venv\Scripts\activate
pip install -r requirements.txt
uvicorn app:app --reload --port 8000
# Swagger: http://localhost:8000/docs
````

> **주의:** 실제 배포 시 내부 서비스 URL(포트)을 환경에 맞게 수정하거나
> `docker-compose` / `Kubernetes Service` 로 name-based 디스커버리를 사용하세요.

---

## 🐳 Docker 사용

```bash
docker build -t sodam-gateway:latest .
docker run -d -p 8000:8000 --name sodam-gateway \
  -e CHAT_SERVICE_URL=http://chat:8001 \
  -e AUTH_SERVICE_URL=http://auth:8002 \
  -e PROFILE_SERVICE_URL=http://profile:8003 \
  -e CHAT_HISTORY_SERVICE_URL=http://history:8004 \
  sodam-gateway:latest
```

---

## 📂 프로젝트 구조

```text
gateway/
├── app.py          # FastAPI BFF
├── __init__.py
├── Dockerfile
└── requirements.txt
```

---

## 🔧 주요 환경 변수

| 변수                         | 기본값                     | 설명             |
| -------------------------- | ----------------------- | -------------- |
| `CHAT_SERVICE_URL`         | `http://localhost:8001` | Chat LLM 프록시   |
| `AUTH_SERVICE_URL`         | `http://localhost:8002` | 인증 서비스         |
| `PROFILE_SERVICE_URL`      | `http://localhost:8003` | 캐릭터 프로필 서비스    |
| `CHAT_HISTORY_SERVICE_URL` | `http://localhost:8004` | 대화 이력 서비스      |
| `PORT`                     | 8000                    | 게이트웨이 외부 노출 포트 |

---

## 📜 라이선스

MIT © 2025 Sodam Team

```
```
