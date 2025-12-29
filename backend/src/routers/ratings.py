from typing import cast
from fastapi import APIRouter, Depends, HTTPException
from database import get_db
from sqlalchemy.orm import Session

from schemas import Message, RatingAverageOut, RatingCreate, RatingOut, RatingUpdate
from models import Rating, Recipe, User


router = APIRouter(
    prefix="/ratings",
    tags=["Ratings"]
)


@router.post("", response_model=RatingOut)
def create_rating(rating: RatingCreate, db: Session = Depends(get_db)):
    if db.query(Rating).filter(Rating.recipe_id == rating.recipe_id, Rating.user_id == rating.user_id).first():
        raise HTTPException(status_code=400, detail="User has already rated this recipe")
    
    if db.query(Recipe).filter(Recipe.id == rating.recipe_id).first() is None:
        raise HTTPException(status_code=404, detail="Recipe not found")
    
    if db.query(User).filter(User.id == rating.user_id).first() is None:
        raise HTTPException(status_code=404, detail="User not found")

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

@router.get("/rating/{rating_id}", response_model=RatingOut)
def get_rating(rating_id: int, db: Session = Depends(get_db)):
    db_rating = db.query(Rating).filter(Rating.id == rating_id).first()

    if not db_rating:
        raise HTTPException(status_code=404, detail="Rating not found")
    
    return db_rating

@router.patch("/rating/{rating_id}", response_model=RatingOut)
def edit_rating(rating_id: int, patch: RatingUpdate, db: Session = Depends(get_db)):
    db_rating = db.query(Rating).filter(Rating.id == rating_id).first()

    if not db_rating:
        raise HTTPException(status_code=404, detail="Rating not found")
    
    is_comment_edited = "comment" in patch.model_dump(exclude_unset=True)

    setattr(db_rating, "stars", patch.stars)
    if is_comment_edited:
        setattr(db_rating, "comment", patch.comment)

    db.commit()
    db.refresh(db_rating)

    return db_rating

@router.delete("/rating/{rating_id}", response_model=Message)
def delete_rating(rating_id: int, db: Session = Depends(get_db)):
    db_rating = db.query(Rating).filter(Rating.id == rating_id).first()

    if not db_rating:
        raise HTTPException(status_code=404, detail="Rating not found")
    
    db.delete(db_rating)
    db.commit()

    return Message(detail="Rating deleted successfully")

@router.get("/{recipe_id}", response_model=list[RatingOut])
def list_ratings(recipe_id: int, db: Session = Depends(get_db)):
    if db.query(Recipe).filter(Recipe.id == recipe_id).first() is None:
        raise HTTPException(status_code=404, detail="Recipe not found")

    return db.query(Rating).filter(Rating.recipe_id == recipe_id).all()

@router.get("/{recipe_id}/average", response_model=RatingAverageOut)
def get_average_rating(recipe_id: int, db: Session = Depends(get_db)):
    if db.query(Recipe).filter(Recipe.id == recipe_id).first() is None:
        raise HTTPException(status_code=404, detail="Recipe not found")

    ratings = db.query(Rating).filter(Rating.recipe_id == recipe_id).all()

    if not ratings or len(ratings) == 0:
        return 0.0

    total_stars = sum(rating.stars for rating in ratings)
    average = total_stars / len(ratings)

    return RatingAverageOut(
        average_stars=round(cast(float, average), 2),
        total_ratings=len(ratings)
    )

@router.delete("/{recipe_id}", response_model=Message)
def delete_all_ratings_from_recipe(recipe_id: int, db: Session = Depends(get_db)):
    if db.query(Recipe).filter(Recipe.id == recipe_id).first() is None:
        raise HTTPException(status_code=404, detail="Recipe not found")

    db.query(Rating).filter(Rating.recipe_id == recipe_id).delete()
    db.commit()

    return Message(detail="All ratings for the recipe have been deleted successfully")
