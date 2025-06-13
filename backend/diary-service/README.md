````markdown
# Sodam Diary-Service

사용자가 작성한 감정 일기(Emotion Diary)를 CRUD 형태로 관리하는 마이크로서비스입니다.  
FastAPI와 SQLite로 구현됐으며, 모바일 앱·Gateway에서 `/api/diary` REST 엔드포인트로 접근합니다.

---

## 엔드포인트

| Path | Method | 설명 |
|------|--------|------|
| `/api/diary` | GET    | 일기 목록(최신순) |
| `/api/diary` | POST   | 새 일기 작성 |
| `/api/diary/{id}` | PUT | 일기 수정 |
| `/api/diary/{id}` | DELETE | 일기 삭제 |
| `/health` | GET | 헬스 체크 |

* 필드: `id`, `date`, `mood`, `category`, `content`  
* SQLite 파일 **`emotion_diary.db`** 자동 생성  
* CORS 전체 허용

---

## 기술 스택

| 구분 | 사용 기술 |
|------|-----------|
| Web  | FastAPI, Uvicorn |
| DB   | SQLite (`sqlite3` 모듈) |

---

## 실행 방법

```bash
# 가상환경 준비
python -m venv .venv
source .venv/bin/activate           # Windows: .\.venv\Scripts\activate

# 의존성 설치
pip install fastapi uvicorn pydantic

# 서버 실행
uvicorn app:app --reload --port 8005
# 문서: http://localhost:8005/docs
````

> 첫 실행 시 `emotion_diary.db` 및 `diary_entries` 테이블이 자동으로 만들어집니다.

---

## 프로젝트 구조

```
diary-service/
├── app.py            # FastAPI 애플리케이션
├── diary_service.py  # Router 분리 버전
├── emotion_diary.db  # SQLite (런타임 생성)
└── requirements.txt
```

---

## 데이터 예시

```json
{
  "id": 1,
  "date": "2025-06-14",
  "mood": "😀",
  "category": "daily",
  "content": "오늘은 Flutter 앱을 완성했다!"
}
```

---

## 환경 변수 (선택)

| 변수        | 기본값                | 설명                |
| --------- | ------------------ | ----------------- |
| `DB_PATH` | `emotion_diary.db` | 다른 경로·파일명 지정 시 사용 |
| `PORT`    | 8005               | Uvicorn 포트 변경 시   |

---
