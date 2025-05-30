# Sodam Backend Services

## 서비스 구조

```
/backend/
├── auth-service/      # 인증 서비스
├── chat-service/      # 채팅 서비스
├── history-service/   # 히스토리 서비스
├── profile-service/   # 프로필 서비스
└── gateway/          # API Gateway
```

## 각 서비스 설명

### Auth Service (8001)
- 사용자 인증 및 인가 처리
- JWT 토큰 기반 인증
- 회원가입, 로그인 기능

### Chat Service (8002)
- AI 챗봇과의 대화 처리
- Ollama API 연동
- 채팅 기록 저장

### History Service (8003)
- 사용자 활동 기록 관리
- 채팅 히스토리 조회
- 통계 데이터 제공

### Profile Service (8004)
- 사용자 프로필 관리
- 설정 관리
- 개인화 데이터 처리

### API Gateway (8000)
- 모든 서비스에 대한 단일 진입점
- 요청 라우팅
- 서비스 디스커버리

## 시작하기

1. 각 서비스 디렉토리에서 의존성 설치:
```bash
pip install -r requirements.txt
```

2. 환경 변수 설정:
각 서비스 디렉토리에 `.env` 파일을 생성하고 필요한 환경 변수를 설정합니다.

3. 서비스 실행:
```bash
# Auth Service
cd auth-service
uvicorn app:app --port 8001

# Chat Service
cd chat-service
uvicorn app:app --port 8002

# History Service
cd history-service
uvicorn app:app --port 8003

# Profile Service
cd profile-service
uvicorn app:app --port 8004

# API Gateway
cd gateway
uvicorn app:app --port 8000
```

## API 문서

각 서비스의 API 문서는 다음 URL에서 확인할 수 있습니다:
- Auth Service: http://localhost:8001/docs
- Chat Service: http://localhost:8002/docs
- History Service: http://localhost:8003/docs
- Profile Service: http://localhost:8004/docs
- API Gateway: http://localhost:8000/docs 