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
    # 필요시 다른 캐릭터도 추가
}

@router.get("/{character}", response_model=ProfileResponse)
async def get_profile(character: str):
    """
    특정 캐릭터의 시스템 프롬프트(프로필) 반환
    GET /api/profile/{character}
    """
    prompt = profiles.get(character)
    if prompt:
        return ProfileResponse(prompt=prompt)
    raise HTTPException(status_code=404, detail="해당 캐릭터를 찾을 수 없어요.")
