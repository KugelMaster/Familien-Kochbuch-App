from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import SessionLocal
from schemas import RecipeCreate, RecipeOut, UserNoteCreate, UserNoteOut, RatingCreate, RatingOut
from crud import recipes

router = APIRouter(prefix="/recipes")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.post("", response_model=RecipeOut)
def create_recipe(recipe: RecipeCreate, db: Session = Depends(get_db)):
    return recipes.create_recipe(db, recipe)

@router.post("/usernote", response_model=UserNoteOut)
def create_usernote(usernote: UserNoteCreate, db: Session = Depends(get_db)):
    return recipes.create_usernote(db, usernote)

@router.post("/rating", response_model=RatingOut)
def create_rating(rating: RatingCreate, db: Session = Depends(get_db)):
    return recipes.create_rating(db, rating)


@router.get("", response_model=list[RecipeOut])
def list_recipes(db: Session = Depends(get_db)):
    return recipes.get_recipes(db)

@router.get("/{recipe_id}/usernotes", response_model=list[UserNoteOut])
def list_usernotes(recipe_id: int, db: Session = Depends(get_db)):
    return recipes.get_usernotes(db, recipe_id)

@router.get("/{recipe_id}/ratings", response_model=list[RatingOut])
def list_ratings(recipe_id: int, db: Session = Depends(get_db)):
    return recipes.get_ratings(db, recipe_id)
