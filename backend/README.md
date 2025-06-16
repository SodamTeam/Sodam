# Backend Monorepo

Flutter 앱 **“Sodam”** 의 모든 마이크로서비스를 담고 있는 백엔드 루트 디렉터리입니다.

| Service | Port | Tech | 설명 |
|---------|------|------|------|
| **API-Gateway**        | **8000** | FastAPI, httpx | BFF. 외부 요청을 내부 서비스로 라우팅 / CORS·스트리밍 프록시 |
| **Chat-Service**       | 8001 | FastAPI, Ollama, SQLite | AI LLM 호출(SSE) + 채팅·책 추천 저장 |
| **Auth-Service**       | 8002 | FastAPI, JWT, SQLite | 회원가입·로그인, 토큰 발급/검증 |
| **Profile-Service**    | 8003 | FastAPI, SQLite | 캐릭터 프로필 CRUD (초기 4종) |
| **Chat-History-Service** | 8004 | FastAPI, SQLite | 사용자별 채팅 히스토리 영구 저장 |
| **Diary-Service**      | 8005 | FastAPI, SQLite | 감정 일기 CRUD |

---

##  디렉터리 구조
```text
backend/
├── auth-service/
├── chat-service/
├── chat_history_service/
├── diary-service/
├── gateway/
├── profile-service/
└── app/                 # 공용 패키지(있다면)
````

---

##  로컬 실행 방법

> 파이썬 3.11+ 권장. 각 서비스 디렉터리마다 `requirements.txt` 가 존재합니다.

```bash
# 0) 공통 : 가상환경
python -m venv .venv
source .venv/bin/activate          # Windows: .\.venv\Scripts\activate

# 1) Auth-Service
cd auth-service
pip install -r requirements.txt
uvicorn app:app --reload --port 8002 &

# 2) Chat-Service
cd ../chat-service
pip install -r requirements.txt
uvicorn app:app --reload --port 8001 &

# 3) Chat-History-Service
cd ../chat_history_service
pip install -r requirements.txt
uvicorn app:app --reload --port 8004 &

# 4) Profile-Service
cd ../profile-service
pip install -r requirements.txt
uvicorn app:app --reload --port 8003 &

# 5) Diary-Service
cd ../diary-service
pip install -r requirements.txt
uvicorn app:app --reload --port 8005 &

# 6) API-Gateway (마지막에 실행)
cd ../gateway
pip install -r requirements.txt
uvicorn app:app --reload --port 8000
```

> 첫 실행 시 각 서비스는 자체적으로 SQLite DB 파일을 생성합니다.

---

##  API 문서 (Swagger UI)

| URL                          | 서비스                  |
| ---------------------------- | -------------------- |
| `http://localhost:8000/docs` | API-Gateway          |
| `http://localhost:8001/docs` | Chat-Service         |
| `http://localhost:8002/docs` | Auth-Service         |
| `http://localhost:8003/docs` | Profile-Service      |
| `http://localhost:8004/docs` | Chat-History-Service |
| `http://localhost:8005/docs` | Diary-Service        |

---

##  개발 메모

* **CORS**: 모든 서비스에서 `allow_origins=["*"]` 개발용 설정. 배포 시 도메인 화이트리스트로 제한 필요.
* **SQLite → RDB**: 추후 PostgreSQL 등으로 교체 검토.
* **환경 변수**: 예시값(디폴트) 사용 중. `.env` 또는 시크릿 매니저로 이전 예정.

---

