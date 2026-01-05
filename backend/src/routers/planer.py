import random
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from database import get_db
from sqlalchemy.orm import Session

from models import Recipe
from schemas import RecipeResponse


router = APIRouter(
    prefix="/planer",
    tags=["Planer"]
)

@router.get("/random-recipe", response_model=RecipeResponse)
def get_random_recipe(db: Session = Depends(get_db)):
    id_list = db.execute(select(Recipe.id)).scalars().all()

    random_id = random.choice(id_list)
    db_recipe = db.query(Recipe).filter(Recipe.id == random_id).first()

    if not db_recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")

    return db_recipe
