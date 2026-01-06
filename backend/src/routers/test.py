from fastapi import APIRouter

from dependencies import user_dependency

router = APIRouter(prefix="/test", tags=["Test"])


@router.get("/protected")
def get_protected_site(user: user_dependency):
    return {"user": user}
