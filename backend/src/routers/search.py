from fastapi import APIRouter

from database import db_dependency
from models import Recipe
from schemas import RecipeOutSimple
from utils.statements import recipe_simple_statement

router = APIRouter(prefix="/search", tags=["Search"])


@router.get("", response_model=list[RecipeOutSimple])
def search_recipe(query: str, db: db_dependency, max_results: int = 10):
    stmt = recipe_simple_statement.where(Recipe.title.ilike(f"%{query}%")).limit(
        max_results
    )
    return db.execute(stmt).all()
