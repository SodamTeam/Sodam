````markdown
# Sodam Profile-Service

이 모듈은 Sodam에 등장하는 캐릭터(하린·세라·유리·미나)의 **프로필—성격, 관심사, 이미지 등**을 보관하고 전달합니다.  
Gateway가 Chat-Service를 호출할 때 프로필 정보를 읽어 챗봇 프롬프트를 만드는 데 활용합니다.

---

## 엔드포인트

| Method | URL | 설명 |
|--------|-----|------|
| **GET**  | `/api/profile/{username}` | 캐릭터 프로필 조회 |
| **PUT**  | `/api/profile/{username}` | 프로필 수정 |
| **POST** | `/{username}`            | 새 프로필 등록(내부용) |

- 서버를 처음 실행하면 하린·세라·유리·미나 4명의 기본 프로필이 자동 입력됩니다.  
- FastAPI + SQLAlchemy + SQLite(`profile.db`)를 사용합니다.  
- CORS는 개발 편의를 위해 전체 허용 상태입니다.

---

## 기술 스택

| 구분 | 사용 기술 |
|------|-----------|
| Backend | FastAPI, Uvicorn |
| ORM/DB  | SQLAlchemy + SQLite |

---

## 사용 방법

```bash
# 가상환경 생성
python -m venv .venv
source .venv/bin/activate        # Windows: .\.venv\Scripts\activate

# 패키지 설치
pip install -r requirements.txt

# (최초 1회) DB 테이블 생성
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
│
├── app.py          # FastAPI 엔트리포인트
├── database.py     # DB 엔진·세션
├── models.py       # SQLAlchemy 모델
├── schemas.py      # Pydantic 스키마
├── requirements.txt
└── profile.db      # SQLite 파일(런타임 생성)
```

---

## 환경 변수 (선택)

| 변수             | 기본값                      | 용도               |
| -------------- | ------------------------ | ---------------- |
| `DATABASE_URL` | `sqlite:///./profile.db` | 다른 DB 사용 시 경로 변경 |
| `PORT`         | 8003                     | Uvicorn 포트 변경    |

---


