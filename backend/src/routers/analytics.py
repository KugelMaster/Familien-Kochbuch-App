from fastapi import APIRouter

router = APIRouter(prefix="/analytics", tags=["Analytics"])


@router.get("/cooking-history", response_model=dict)
def get_cooking_history():
    return {"test": "test"}
