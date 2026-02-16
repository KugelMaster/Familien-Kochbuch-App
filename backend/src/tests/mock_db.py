import json
from contextlib import contextmanager
from datetime import timezone
from typing import Any, Type, cast

from pydantic import BaseModel
from sqlalchemy import create_engine, event
from sqlalchemy.orm import Session, sessionmaker

from models import Base, Image, Recipe, Tag
from models.analytics import CookingHistory, RecipeCooked
from models.recipe import Ingredient, Nutrition
from models.user import Rating, RecipeNote
from schemas import RecipeResponse
from utils.statements import ensure_exists


@contextmanager
def create_mock_session():
    # Create an in-memory SQLite database
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)

    # Event listener to restore timezone info for datetime fields
    @event.listens_for(RecipeCooked, "load")
    def restore_recipe_cooked_timezone(target: Any, context: Any):  # type: ignore
        if target.last_cooked and target.last_cooked.tzinfo is None:
            target.last_cooked = target.last_cooked.replace(tzinfo=timezone.utc)

    @event.listens_for(CookingHistory, "load")
    def restore_cooking_history_timezone(target: Any, context: Any):  # type: ignore
        if target.cooked_at and target.cooked_at.tzinfo is None:
            target.cooked_at = target.cooked_at.replace(tzinfo=timezone.utc)

    Session = sessionmaker(bind=engine)
    session = Session()

    try:
        yield session
    finally:
        session.close()


def load_json_fixture(
    session: Session,
    json_path: str,
    model: Type[Base],
    schema: Type[BaseModel] | None = None,
):
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    def create_instance(item: Any) -> Base:
        if schema is not None:
            return model(**schema.model_validate(item).model_dump())
        else:
            return model(**item)

    if isinstance(data, list):
        for item in cast(list[Any], data):
            instance = create_instance(item)
            session.add(instance)
    else:
        instance = create_instance(data)
        session.add(instance)
    session.commit()


def create_recipe(db: Session, obj: RecipeResponse) -> Recipe:
    if obj.image_id is not None:
        ensure_exists(
            db,
            Image.id == obj.image_id,
            ValueError("Image not found"),
        )

    if obj.recipe_uri is not None and obj.recipe_uri.strip() == "":
        obj.recipe_uri = None

    # If all conditions are met, create the recipe
    db_recipe = Recipe(
        title=obj.title,
        image_id=obj.image_id,
        description=obj.description,
        time_prep=obj.time_prep,
        time_total=obj.time_total,
        portions=obj.portions,
        recipe_uri=obj.recipe_uri,
    )

    db.add(db_recipe)
    db.commit()
    db.refresh(db_recipe)

    for ingredient in obj.ingredients:
        db_ingredient = Ingredient(
            recipe_id=db_recipe.id,
            name=ingredient.name,
            amount=ingredient.amount,
            unit=ingredient.unit,
        )
        db.add(db_ingredient)

    for nutrition in obj.nutritions:
        db_nutrition = Nutrition(
            recipe_id=db_recipe.id,
            name=nutrition.name,
            amount=nutrition.amount,
            unit=nutrition.unit,
        )
        db.add(db_nutrition)

    for note in obj.recipe_notes:
        db_note = RecipeNote(
            recipe_id=db_recipe.id,
            user_id=note.user_id,
            content=note.content,
        )
        db.add(db_note)

    for rating in obj.ratings:
        db_rating = Rating(
            recipe_id=db_recipe.id,
            user_id=rating.user_id,
            stars=rating.stars,
            comment=rating.comment,
        )
        db.add(db_rating)

    for tag in obj.tags:
        db_tag = db.query(Tag).filter(Tag.id == tag.id).first()
        if db_tag is None:
            db_tag = Tag(id=tag.id, name=tag.name)
            db.add(db_tag)
            db.commit()
            db.refresh(db_tag)

        db_recipe.tags.append(db_tag)

    db.commit()
    return db_recipe


def create_recipes(db: Session, json_path: str):
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    if isinstance(data, list):
        for item in cast(list[Any], data):
            create_recipe(db, RecipeResponse(**item))
    else:
        create_recipe(db, RecipeResponse(**data))
