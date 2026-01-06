from typing import Annotated, Any

from fastapi import APIRouter, Depends

from utils.authentication import get_current_user

router = APIRouter(prefix="/test", tags=["Test"])


@router.get("/protected")
def get_protected_site(
    user: Annotated[dict[str, Any], Depends(get_current_user)],
):
    return {"user": user}
