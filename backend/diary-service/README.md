# Diary-Service

사용자가 작성한 **감정 일기(Emotion Diary)** 를 CRUD 형태로 관리하는 마이크로서비스입니다.  
FastAPI + SQLite 로 구현되어 있으며 Gateway·모바일 앱에서 /api/diary REST 엔드포인트로 접근합니다.

![FastAPI](https://img.shields.io/badge/FastAPI-0.111.0-009688?logo=fastapi&logoColor=white)
![Python](https://img.shields.io/badge/python-3.11-blue)
![License](https://img.shields.io/badge/license-MIT-green)

---

##  API 요약

| Path | Method | 설명 |
|------|--------|------|
| /api/diary | **GET** | 일기 전체 목록(최신순) |
| /api/diary | **POST** | 새 일기 작성 |
| /api/diary/{id} | **PUT** | 일기 수정 |
| /api/diary/{id} | **DELETE** | 일기 삭제 |
| /health | **GET** | 헬스 체크 – {"status":"diary-service OK"} |

* 필드: id, date, mood, category, content  
* SQLite 파일: **emotion_diary.db** 자동 생성  
* 전역 CORS 허용

---

##  기술 스택

| Layer | Tech |
|-------|------|
| Framework | FastAPI, Uvicorn |
| DB | SQLite (sqlite3 모듈) |
| Container | Docker (옵션) |

---

##  빠른 시작

bash
# 1) 의존성
python -m venv .venv && source .venv/bin/activate   # Win: .\.venv\Scripts\activate
pip install fastapi uvicorn pydantic

# 2) 서버 실행
uvicorn app:app --reload --port 8005
# Swagger UI: http://localhost:8005/docs


> 첫 실행 시 emotion_diary.db 및 diary_entries 테이블이 자동으로 만들어집니다.

---

##  프로젝트 구조

text
diary-service/
├── app.py            # 메인 FastAPI 애플리케이션
├── diary_service.py  # (라우터 분리 버전)
├── emotion_diary.db  # SQLite (런타임 생성)
└── requirements.txt


> diary_service.py 는 Router 분리 버전이며, 메인 app.py 만으로도 동일 기능을 제공합니다.

---

## 모델 스키마

jsonc
{
  "id": 1,
  "date": "2025-06-14",
  "mood": "😀",
  "category": "daily",
  "content": "오늘은 Flutter 앱을 완성했다!"
}


---

##  환경 변수 (옵션)

| 변수        | 기본값                | 설명                   |
| --------- | ------------------ | -------------------- |
| DB_PATH | emotion_diary.db | 다른 경로·파일명 사용 시 오버라이드 |
| PORT    | 8005               | Uvicorn 포트 변경 시      |

---
