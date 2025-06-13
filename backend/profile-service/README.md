````markdown
# Sodam Profile-Service

이 서비스는 Sodam 캐릭터 프로필(이름, 성격, 관심사, 이미지)을 저장하고 제공합니다.  
Gateway가 Chat-Service 호출 시 프로필 정보를 읽어 AI 프롬프트를 만드는 데 사용합니다.

---

## 엔드포인트

| HTTP | URI | 설명 |
|------|-----|------|
| GET    | `/api/profile/{username}` | 프로필 조회<br>(초기 데이터: harin, sera, yuri, mina) |
| PUT    | `/api/profile/{username}` | 프로필 수정 |
| POST   | `/{username}`             | 신규 프로필 추가(내부용) |

특징  
* 서버 시작 시 기본 프로필 4개 자동 삽입  
* FastAPI + SQLAlchemy + SQLite(`profile.db`)  
* CORS 전체 허용

---

## 기술 스택

| 구분 | 사용 기술 |
|------|-----------|
| Web  | FastAPI, Uvicorn |
| DB   | SQLite (SQLAlchemy ORM) |

---

## 실행 방법

```bash
# 가상 환경 구성
python -m venv .venv
source .venv/bin/activate        # Windows: .\.venv\Scripts\activate

# 의존성 설치
pip install -r requirements.txt

# DB 스키마 생성
python - <<'PY'
from database import Base, engine
import models
Base.metadata.create_all(bind=engine)
PY

# 서버 실행
uvicorn app:app --reload --port 8003
# 문서: http://localhost:8003/docs
````

---

## 프로젝트 구조

```
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

| 변수             | 기본값                      | 용도                  |
| -------------- | ------------------------ | ------------------- |
| `DATABASE_URL` | `sqlite:///./profile.db` | 다른 RDBMS 사용 시 경로 변경 |
| `PORT`         | 8003                     | Uvicorn 실행 포트       |

---
