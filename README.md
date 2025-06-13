# 소담 (Sodam)

**일상에 스며드는 AI 친구, 소담**

Flutter를 사용하여 개발된 소담은 다양한 개성과 매력을 지닌 AI 캐릭터들과 대화를 나누고 감정을 기록하는 힐링 챗봇 앱입니다.

---

## 주요 기능

- AI 캐릭터와의 대화 기능
- SQLite를 활용한 로컬 데이터베이스 저장
- 다양한 AI 캐릭터 (세라, 유리, 하린, 미나)
- 각 캐릭터별 특화된 대화 스타일과 성격
- 실시간 대화 저장 및 히스토리 관리

---

## 기술 스택

### 프론트엔드
- Flutter
- SQLite (로컬 데이터베이스)
- MySQL (감정일기 데이터베이스)

### 백엔드
- Ollama (AI 모델)
- FastAPI (서버)

---

## 시작하기

1. Flutter 개발 환경 설정
   - [Flutter 설치 가이드](https://docs.flutter.dev/get-started/install)

2. 프로젝트 클론
   ```
   git clone [repository-url]
   ```

3. 의존성 설치
   ```
   flutter pub get
   ```

4. 백엔드 서버 실행
   ```
   cd backend
   uvicorn main:app --reload
   ```

5. 앱 실행
   ```
   flutter run
   ```

---

## 프로젝트 구조

```plaintext
backend/ 마이크로서비스 아키텍처로 구성되어 있어 서비스별로 독립적인 개발과 유지보수가 가능하도록 설계되었습니다.
├── app/ # 공통 설정 및 유틸
│
├── auth-service/ # 사용자 인증 서비스
│ ├── app.py # FastAPI 엔트리포인트
│ ├── database.py # DB 연결
│ ├── models.py # ORM 모델 정의
│ ├── schemas.py # Pydantic 스키마
│ ├── auth.db # SQLite DB
│ └── README.md
│
├── chat-service/ # AI 채팅 생성 서비스
│ ├── app.py
│ ├── database.py
│ ├── models.py
│ ├── schemas.py
│ └── README.md
│
├── chat-history-service/ # 채팅 기록 관리 서비스
│ ├── app.py
│ ├── database.py
│ ├── models.py
│ ├── schemas.py
│ ├── history.db
│ └── README.md
│
├── diary-service/ # 감정 다이어리 기능
│ ├── app.py
│ ├── diary_service.py
│ ├── emotion_diary.db
│ └── README.md
│
├── profile-service/ # 캐릭터 프로필 관리
│ ├── app.py
│ ├── database.py
│ ├── models.py
│ ├── schemas.py
│ ├── profile.db
│ └── README.md
│
├── gateway/ # API Gateway
│ ├── app.py
│ └── README.md
│
├── main.py # 전체 서버 실행 진입점
├── requirements.txt # 공통 의존성 목록
└── README.md
```
---
```plaintext
lib/ 사용자의 감정을 공감하고 소통할 수 있는 AI 캐릭터와의 대화 UI를 Flutter로 구현했습니다.
├── main.dart # 앱 실행 진입점
│
├── screens/ # 모든 UI 화면
│ ├── main_screen.dart
│ ├── chat/
│ │ ├── mina_chat.dart # 감정 공감형 캐릭터 '미나'
│ │ ├── yuri_chat.dart # 과학 소녀 '유리'
│ │ ├── sera_chat.dart # 상담 캐릭터 '세라'
│ │ └── harin_chat.dart # 문학 소녀 '하린'
│ ├── diary/
│ │ ├── emotion_diary.dart # 감정 일기 작성 화면
│ │ └── encouragement.dart # 위로 메시지 화면
│ ├── meditation/
│ │ └── meditation_content.dart # 명상 콘텐츠 재생
│
├── services/ # API 및 DB 서비스 모듈
│ ├── chat_service.dart
│ ├── chat_service_sqlite.dart
│ ├── db_service_sqlite.dart
│ └── profile_service.dart
│
├── config/
│ └── config.dart # API 주소 등 환경 설정
│
├── models/
│ └── chat_message.dart # 메시지 모델 클래스
│
└── widgets/
└── loading_spinner.dart # 공통 로딩 UI 위젯
```
---

## 문의

프로젝트에 관심이 있으시다면 mintori@hknu.ac.kr로 메일을 보내주세요.
