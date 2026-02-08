from fastapi import HTTPException
from sqlalchemy import ColumnElement, exists, func, select
from sqlalchemy.orm import Session

from models import Rating, Recipe
from utils.http_exceptions import ServiceException

recipe_simple_statement = (
    select(
        Recipe.id,
        Recipe.title,
        Recipe.image_id,
        Recipe.time_total,
        func.coalesce(func.avg(Rating.stars), 0.0).label("rating"),
        func.count(Rating.id).label("total_ratings"),
    )
    .outerjoin(Rating)
    .group_by(Recipe.id)
    .order_by(Recipe.id)
)


def ensure_exists(
    session: Session,
    condition: ColumnElement[bool],
    http_exception: HTTPException | ServiceException,
) -> None:
    if not session.scalar(select(exists().where(condition))):
        raise http_exception
