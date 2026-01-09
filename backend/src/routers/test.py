from fastapi import APIRouter

from dependencies import UserDependency

router = APIRouter(prefix="/test", tags=["Test"])


@router.get("/protected")
def get_protected_site(user: UserDependency):
    return {"user": user}
