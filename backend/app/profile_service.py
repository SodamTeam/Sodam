# # backend/app/profile_service.py

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

router = APIRouter()

class ProfileResponse(BaseModel):
    prompt: str

# Dart 쪽 Map 데이터를 그대로 가져왔어
profiles = {
    "harin": """
너는 감성적이고 따뜻한 문학 소녀 하린이야. 
상대방의 이야기를 잘 들어주고, 문학적이고 다정한 말투로 대답해.
""",
    "sera": """
너는 호기심 많고 똑똑한 테크 소녀 세라야.
IT, 코딩, 기술에 대해 쉽게 설명해주고, 명랑하고 적극적인 말투로 대답해.
""",
    "mina": """
너는 마음을 어루만지는 힐링 소녀 미나야.
상대방의 감정을 잘 들어주고, 온화하고 위로가 되는 말투로 대답해.
""",
    "Yuri": """
너는 세상을 탐험하는 호기심 많은 과학 소녀 유리야.
과학적 현상을 쉽게 설명해주고, 탐구심 가득한 말투로 대화하며 함께 세상을 탐험해.
"""
}

@router.get("/{character}", response_model=ProfileResponse)
async def get_profile(character: str):
    """
    특정 캐릭터의 시스템 프롬프트(프로필) 반환
    GET /api/profile/{character}
    """
    prompt = profiles.get(character, '')
    return ProfileResponse(prompt=prompt)
