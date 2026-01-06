from sqlalchemy import ColumnElement, exists, func, select
from sqlalchemy.orm import Session

from models import Rating, Recipe

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


def check_exists(session: Session, condition: ColumnElement[bool]) -> bool:
    return bool(session.scalar(select(exists().where(condition))))
