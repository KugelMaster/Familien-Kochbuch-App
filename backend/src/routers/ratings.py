from fastapi import APIRouter, Depends
from database import get_db
from sqlalchemy.orm import Session

from schemas import RatingCreate, RatingOut
from models import Rating


router = APIRouter(
    prefix="/ratings",
    tags=["Ratings"]
)


@router.post("", response_model=RatingOut)
def create_rating(rating: RatingCreate, db: Session = Depends(get_db)):
    db_rating = Rating(
        recipe_id=rating.recipe_id,
        user_id=rating.user_id,
        stars=rating.stars,
        comment=rating.comment
    )

    db.add(db_rating)
    db.commit()
    db.refresh(db_rating)

    return db_rating

@router.get("/{recipe_id}", response_model=list[RatingOut])
def list_ratings(recipe_id: int, db: Session = Depends(get_db)):
    return db.query(Rating).filter(Rating.recipe_id == recipe_id).all()
