import subprocess
import sys
import os
from threading import Thread
import time
import uvicorn

def run_service(service_name, service_dir, port):
    """서비스를 실행하는 함수"""
    print(f"Starting {service_name}...")
    os.chdir(service_dir)  # 서비스 디렉토리로 이동
    process = subprocess.Popen(
        [sys.executable, "-m", "uvicorn", "app:app", "--host", "0.0.0.0", "--port", str(port)]
    )
    os.chdir(os.path.dirname(os.path.dirname(service_dir)))  # 원래 디렉토리로 복귀
    return process

def main():
    # 현재 디렉토리 저장
    current_dir = os.path.dirname(os.path.abspath(__file__))
    
    # 각 서비스 실행
    processes = []
    
    # Gateway Service (8000 포트)
    gateway_process = run_service(
        "Gateway Service",
        os.path.join(current_dir, "gateway"),
        8000
    )
    processes.append(gateway_process)
    time.sleep(2)  # 서비스 시작 대기
    
    # Chat Service (8001 포트)
    chat_process = run_service(
        "Chat Service",
        os.path.join(current_dir, "chat-service"),
        8001
    )
    processes.append(chat_process)
    time.sleep(2)
    
    # Auth Service (8002 포트)
    auth_process = run_service(
        "Auth Service",
        os.path.join(current_dir, "auth-service"),
        8002
    )
    processes.append(auth_process)
    time.sleep(2)
    
    # Profile Service (8003 포트)
    profile_process = run_service(
        "Profile Service",
        os.path.join(current_dir, "profile-service"),
        8003
    )
    processes.append(profile_process)
    time.sleep(2)
    
    # Chat History Service (8004 포트)
    history_process = run_service(
        "Chat History Service",
        os.path.join(current_dir, "chat_history_service"),
        8004
    )
    processes.append(history_process)
    
    try:
        # 모든 프로세스가 종료될 때까지 대기
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\nShutting down all services...")
        for process in processes:
            process.terminate()
        
        # 모든 프로세스가 종료될 때까지 대기
        for process in processes:
            process.wait()
        print("All services have been shut down.")

if __name__ == "__main__":
    main() 