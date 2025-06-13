# 소담 (Sodam) 👋

**일상에 스며드는 AI 친구, 소담**은 Flutter를 사용하여 개발된 힐링 챗봇 앱입니다.  
다양한 개성과 매력을 지닌 AI 캐릭터들과 대화를 나누고 감정을 기록할 수 있습니다.

## 주요 기능
- AI 캐릭터와의 대화 기능  
- SQLite를 활용한 로컬 데이터베이스 저장  
- 다양한 AI 캐릭터 (세라, 유리, 하린, 미나) 지원  
- 각 캐릭터별 특화된 대화 스타일과 성격  
- 실시간 대화 저장 및 히스토리 관리  

## 기술 스택
<details>
<summary>프론트엔드</summary>

- Flutter  
- SQLite (로컬 데이터베이스)  
- SQLite (감정일기 데이터베이스)  
</details>

<details>
<summary>백엔드</summary>

- Ollama (AI 모델)  
- FastAPI (서버)  
</details>

## 시작하기

### 1. Flutter 개발 환경 설정
- Flutter 설치 가이드 참조

### 2. 프로젝트 클론
```bash
git clone [repository-url]
```

### 3. 의존성 설치
```bash
cd sodam_app
flutter pub get
```

### 4. 백엔드 서버 실행
```bash
cd backend
uvicorn main:app --reload
```

### 5. 앱 실행
```bash
flutter run
```

## 프로젝트 구조
```
sodam_app/
├─ lib/
│  ├─ main.dart                  # 앱 진입점
│  ├─ screens/                   # 화면 관련 코드
│  │  ├─ sera_chat.dart          # 세라 캐릭터 채팅 구현
│  │  ├─ yuri_chat.dart          # 유리 캐릭터 채팅 구현
│  │  ├─ harin_chat.dart         # 하린 캐릭터 채팅 구현
│  │  └─ mina_chat.dart          # 미나 캐릭터 채팅 구현
│  └─ services/
│     ├─ chat_service.dart           # 채팅 서비스 인터페이스
│     ├─ chat_service_sqlite.dart    # SQLite 채팅 서비스 구현
│     └─ profile_service.dart        # 프로필 관리 서비스
├─ backend/
│  ├─ main.py                    # FastAPI 서버 진입점
│  ├─ routers/
│  │  └─ auth.py                 # 인증 관련 API
│  └─ models/
│     └─ emotion_log.py          # 감정일기 데이터 모델
└─ README.md                     # 프로젝트 설명 문서
```

## 문의
프로젝트에 관심이 있으시다면 mintori@hknu.ac.kr로 메일을 보내주세요.
