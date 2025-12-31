from fastapi import APIRouter, Depends
from sqlalchemy import select
from database import get_db
from sqlalchemy.orm import Session

from schemas import RecipeOutSimple
from models import Recipe


router = APIRouter(
    prefix="/search",
    tags=["Search"]
)


@router.get("", response_model=list[RecipeOutSimple])
def search_recipe(query: str, max_results: int = 10, db: Session = Depends(get_db)):
    stmt = select(Recipe.id, Recipe.title).where(Recipe.title.ilike(f"%{query}%")).limit(max_results)
    return db.execute(stmt).all()
