FROM python:3.11-slim

WORKDIR /app

# 필요한 시스템 패키지 설치
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# requirements.txt 복사 및 의존성 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 소스 코드 복사
COPY auth-service/ .

# 포트 노출
EXPOSE 8002

# 서비스 실행
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8002"] 