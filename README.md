# 소담 (Sodam)

**일상에 스며드는 AI 친구, 소담**
Flutter를 사용하여 개발된 소담은 다양한 개성과 매력을 지닌 AI 캐릭터들과 대화를 나누고 감정을 기록하는 힐링 챗봇 앱입니다.

---

## 주요 기능

- AI 캐릭터와의 대화 기능
- SQLite를 활용한 로컬 데이터베이스 저장
- 다양한 AI 캐릭터 (세라, 유리, 하린, 미나) 지원
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

- `lib/`: 주요 소스 코드
  - `main.dart`: 앱의 진입점
  - `screens/`: 화면 관련 코드
  - `*_chat.dart`: 각 AI 캐릭터별 채팅 구현
    - `sera_chat.dart`: 세라 캐릭터 구현
    - `yuri_chat.dart`: 유리 캐릭터 구현
    - `harin_chat.dart`: 하린 캐릭터 구현
  - `*_service.dart`: 데이터베이스 및 프로필 서비스
    - `chat_service.dart`: 채팅 관련 서비스
    - `chat_service_sqlite.dart`: SQLite 채팅 서비스
    - `profile_service.dart`: 프로필 관리 서비스

---

## 문의

프로젝트에 관심이 있으시다면 mintori@hknu.ac.kr로 메일을 보내주세요.
