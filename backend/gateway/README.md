````markdown
# Sodam API-Gateway

여러 마이크로서비스를 하나의 `/api/*` 엔드포인트로 묶어 주는 게이트웨이입니다.  
FastAPI와 httpx를 이용해 Chat, Auth, Profile, History 서비스 호출을 대신 수행하고 CORS 정책을 통일합니다.

---

## 라우팅

| Gateway 경로 | 연결 대상 | 실제 URL |
|--------------|-----------|----------|
| `POST /api/chat/generate` | chat-service | `http://localhost:8001/api/chat/generate` |
| `POST /api/chat` | chat-service | `…/chat` |
| `GET /api/chat/history/{user_id}/{room}` | chat-history-service | `http://localhost:8004/history/{user_id}/{room}` |
| `POST /api/chat/history` | chat-history-service | `…/history/` |
| `POST /api/auth/login` | auth-service | `http://localhost:8002/login` |
| `POST /api/auth/signup` | auth-service | `…/signup` |
| `GET /api/auth/users/me` | auth-service | `…/auth/users/me` |
| `GET /api/profile/{character}` | profile-service | `http://localhost:8003/api/profile/{character}` |

* `/api/chat/generate`는 **SSE 스트림**을 그대로 전달합니다.  
* CORS 전체 허용, 서비스 호출 타임아웃 30초.

---

## 사용 기술

| 구분 | 내용 |
|------|------|
| Web  | FastAPI |
| HTTP | httpx 0.27 |
| 실행 | Uvicorn |

---

## 실행 방법

```bash
python -m venv .venv
source .venv/bin/activate            # Windows: .\.venv\Scripts\activate
pip install -r requirements.txt

uvicorn app:app --reload --port 8000
# 문서: http://localhost:8000/docs
````

> 배포 환경에서는 내부 서비스 URL(포트)을 인프라에 맞게 조정하거나
> 서비스 디스커버리(`docker-compose`, Kubernetes 등)를 사용하세요.

---

## 프로젝트 구조

```
gateway/
├── app.py          # FastAPI BFF
├── __init__.py
└── requirements.txt
```

---

## 환경 변수

| 변수                         | 기본값                     | 설명           |
| -------------------------- | ----------------------- | ------------ |
| `CHAT_SERVICE_URL`         | `http://localhost:8001` | Chat 서비스 URL |
| `AUTH_SERVICE_URL`         | `http://localhost:8002` | 인증 서비스 URL   |
| `PROFILE_SERVICE_URL`      | `http://localhost:8003` | 프로필 서비스 URL  |
| `CHAT_HISTORY_SERVICE_URL` | `http://localhost:8004` | 히스토리 서비스 URL |
| `PORT`                     | 8000                    | 게이트웨이 포트     |

---
