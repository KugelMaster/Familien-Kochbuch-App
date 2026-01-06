from fastapi import APIRouter
from starlette import status

from dependencies import DBDependency, UserDependency
from models import Rating, Recipe
from schemas import Message, RatingAverageOut, RatingCreate, RatingOut, RatingUpdate
from utils.http_exceptions import BadRequest, Forbidden, NotFound
from utils.statements import ensure_exists

router = APIRouter(prefix="/ratings", tags=["Ratings"])


@router.post("", response_model=RatingOut, status_code=status.HTTP_201_CREATED)
def create_rating(rating: RatingCreate, db: DBDependency, user: UserDependency):
    if (
        db.query(Rating)
        .filter(Rating.recipe_id == rating.recipe_id, Rating.user_id == user.id)
        .first()
    ):
        raise BadRequest("User has already rated this recipe")

    ensure_exists(db, Recipe.id == rating.recipe_id, NotFound("Recipe not found"))

    db_rating = Rating(
        recipe_id=rating.recipe_id,
        user_id=user.id,
        stars=rating.stars,
        comment=rating.comment,
    )

    db.add(db_rating)
    db.commit()
    db.refresh(db_rating)

    return db_rating


@router.get("/rating/{rating_id}", response_model=RatingOut)
def get_rating(rating_id: int, db: DBDependency):
    db_rating = db.query(Rating).filter(Rating.id == rating_id).first()

    if not db_rating:
        raise NotFound("Rating not found")

    return db_rating


@router.patch("/rating/{rating_id}", response_model=RatingOut)
def edit_rating(
    rating_id: int, patch: RatingUpdate, db: DBDependency, user: UserDependency
):
    db_rating = db.query(Rating).filter(Rating.id == rating_id).first()

    if not db_rating:
        raise NotFound("Rating not found")

    if db_rating.user_id != user.id and not user.is_admin:
        raise Forbidden("Forbidden: You do not have permission to edit this rating.")

    is_comment_edited = "comment" in patch.model_dump(exclude_unset=True)

    setattr(db_rating, "stars", patch.stars)
    if is_comment_edited:
        setattr(db_rating, "comment", patch.comment)

    db.commit()
    db.refresh(db_rating)

    return db_rating


@router.delete("/rating/{rating_id}", response_model=Message)
def delete_rating(rating_id: int, db: DBDependency, user: UserDependency):
    db_rating = db.query(Rating).filter(Rating.id == rating_id).first()

    if not db_rating:
        raise NotFound("Rating not found")

    if db_rating.user_id != user.id and not user.is_admin:
        raise Forbidden("Forbidden: You do not have permissions to delete this rating.")

    db.delete(db_rating)
    db.commit()

    return Message(detail="Rating deleted successfully")


@router.get("/{recipe_id}", response_model=list[RatingOut])
def list_ratings(recipe_id: int, db: DBDependency):
    ensure_exists(db, Recipe.id == recipe_id, NotFound("Recipe not found"))

    return db.query(Rating).filter(Rating.recipe_id == recipe_id).all()


@router.get("/{recipe_id}/average", response_model=RatingAverageOut)
def get_average_rating(recipe_id: int, db: DBDependency):
    ensure_exists(db, Recipe.id == recipe_id, NotFound("Recipe not found"))

    ratings = db.query(Rating).filter(Rating.recipe_id == recipe_id).all()

    if not ratings or len(ratings) == 0:
        return RatingAverageOut(average_stars=0.0, total_ratings=0)

    total_stars = sum(rating.stars for rating in ratings)
    average = total_stars / len(ratings)

    return RatingAverageOut(average_stars=round(average, 2), total_ratings=len(ratings))


@router.delete("/{recipe_id}", response_model=Message)
def delete_all_ratings_from_recipe(
    recipe_id: int, db: DBDependency, user: UserDependency
):
    ensure_exists(db, Recipe.id == recipe_id, NotFound("Recipe not found"))

    if not user.is_admin:
        raise Forbidden(
            "Forbidden: You do not have permissions to delete all ratings from this recipe."
        )

    db.query(Rating).filter(Rating.recipe_id == recipe_id).delete()
    db.commit()

    return Message(detail="All ratings for the recipe have been deleted successfully")
