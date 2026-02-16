from fastapi import APIRouter

from dependencies import DBDependency, UserDependency
from models import CookingHistory, RecipeCooked
from models.recipe import Recipe
from schemas import (
    CookingHistoryCreate,
    CookingHistoryOut,
    CookingHistoryOutMultiple,
    CookingHistoryOutSingle,
)
from utils.http_exceptions import NotFound
from utils.statements import ensure_exists

router = APIRouter(prefix="/analytics", tags=["Analytics"])


@router.get("/cooking-history", response_model=CookingHistoryOutMultiple)
def get_cooking_history(db: DBDependency, limit: int = 10):
    history = (
        db.query(CookingHistory).order_by(CookingHistory.id.desc()).limit(limit).all()
    )

    times_cooked = (
        db.query(RecipeCooked)
        .filter(RecipeCooked.recipe_id.in_([h.recipe_id for h in history]))
        .all()
    )

    return CookingHistoryOutMultiple(
        history=[CookingHistoryOut.model_validate(h) for h in history],
        times_cooked=[(c.recipe_id, c.times_cooked) for c in times_cooked],
    )


@router.post("/cooking-history", response_model=CookingHistoryOutSingle)
def create_cooking_history(
    history: CookingHistoryCreate, db: DBDependency, user: UserDependency
):
    ensure_exists(db, Recipe.id == history.recipe_id, NotFound("Recipe not found"))

    db_cooked = (
        db.query(RecipeCooked)
        .filter(RecipeCooked.recipe_id == history.recipe_id)
        .first()
    )

    if db_cooked:
        db_cooked.times_cooked += 1
        db_cooked.last_cooked = history.cooked_at
    else:
        db_cooked = RecipeCooked(
            recipe_id=history.recipe_id, times_cooked=1, last_cooked=history.cooked_at
        )

    db_history = CookingHistory(
        recipe_id=history.recipe_id,
        cooked_by=user.user_id,
        cooked_at=history.cooked_at,
    )

    db.add(db_cooked)
    db.add(db_history)
    db.commit()
    db.refresh(db_history)

    return CookingHistoryOutSingle(
        id=db_history.id,
        recipe_id=db_history.recipe_id,
        cooked_by=db_history.cooked_by,
        cooked_at=db_history.cooked_at,
        times_cooked=db_cooked.times_cooked,
    )
