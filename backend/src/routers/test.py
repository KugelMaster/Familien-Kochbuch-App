from fastapi import APIRouter, HTTPException

from dependencies import UserDependency

router = APIRouter(prefix="/test", tags=["Test"])


@router.get("/protected")
def get_protected_site(user: UserDependency):
    return {"user": user}


@router.get("/{error_code}")
def test_error(error_code: int):
    raise HTTPException(status_code=error_code, detail="This is a test error.")
