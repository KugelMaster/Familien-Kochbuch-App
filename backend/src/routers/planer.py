from fastapi import APIRouter
from sqlalchemy import ColumnElement, and_, func

from dependencies import DBDependency, UserDependency
from models.recipe import Recipe, Tag
from schemas import RecipeResponse
from utils.http_exceptions import BadRequest

router = APIRouter(prefix="/planer", tags=["Planer"])


def random_recipe_with_filter(
    stmt: ColumnElement[bool], db: DBDependency
) -> Recipe | None:
    return db.query(Recipe).filter(stmt).order_by(func.random()).first()


@router.get("/random", response_model=list[RecipeResponse])
def get_random_recipe(db: DBDependency, user: UserDependency, amount: int = 1):
    if amount < 1:
        raise BadRequest("Amount must be at least 1")

    db_recipes = db.query(Recipe).order_by(func.random()).limit(amount).all()

    return db_recipes


@router.get("/day", response_model=dict[str, RecipeResponse | None])
def get_plan_for_one_day(db: DBDependency, user: UserDependency):
    meals = {"breakfast": "Frühstück", "lunch": "Mittagessen", "dinner": "Abendessen"}

    db_recipes: dict[str, Recipe | None] = {}
    used_ids: set[int] = set()

    for meal, tag_name in meals.items():
        tag_id = db.query(Tag.id).filter(Tag.name == tag_name).first()
        if tag_id:
            recipe = random_recipe_with_filter(
                and_(Recipe.tags.any(Tag.id == tag_id[0]), Recipe.id.not_in(used_ids)),
                db,
            )
            db_recipes[meal] = recipe
            if recipe:
                used_ids.add(recipe.id)
        else:
            db_recipes[meal] = None

    return db_recipes
