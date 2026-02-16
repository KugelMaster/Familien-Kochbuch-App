import sys
from datetime import datetime, timezone

sys.path.append(
    "C:\\Users\\Florian\\Documents\\GitHub\\Familien-Kochbuch-App\\backend\\src"
)

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from models.analytics import RecipeCooked
from models.recipe import Recipe, Tag

# Einfach:
# Wie viele Rezepte?

# Schwieriger:
# Zutaten?
# Nährstoffe?
# Ausbalancierte Nährstoffe?
# Welche Benutzergruppe (z.B. IDs 1, 2, 4)
# -> Benutzer-Vorlieben
# Keine Wiederholung
# Saisonalität


def get_random_recipes(
    db: Session,
    amount: int = 1,
    tags: list[int] | None = None,
    max_time_prep: float | None = None,
    max_time_total: float | None = None,
    for_people: list[int] | None = None,
    ignore: list[int] | None = None,
    # ingredients: list | None = None,
    # nutritions: list | None = None,
) -> list[Recipe]:
    """
    Get random recipes from the database. Set the parameters for a more precise choice.

    Args:
        db (Session): The database Session
        amount (int, optional): The amount of recipes to return. Might be less than defined depending on the filters. Defaults to 1.
        tags (list[int] | None, optional): Filter for tags (please only supply IDs). Defaults to None.
        max_time_prep (float | None, optional): The max time the recipe should take to prepare and work on. Defaults to None.
        max_time_total (float | None, optional): The max time the recipe should take in total. Defaults to None.
        for_people (list[int] | None, optional): Define a group of users here for a better choice. This will be used to make everyone more happy :-) (please only supply user IDs). Defaults to None.
        ignore (list[int] | None, optional): A list of recipe IDs to ignore. Defaults to None.
        ingredients (list | None, optional): The available ingredients in total. Useful for retrieving recipes e.g. depending on whats left in the fridge. This parameter is WIP and due to change! Defaults to None.
        nutritions (list | None, optional): This parameter is WIP and due to change! Define here the min. or max. amount of nutritions the recipes should contain in total. Defaults to None.

    Raises:
        BadRequest: _description_

    Returns:
        list[Recipe]: The suitable recipes found depending on the set filters.
    """

    stmt = select(Recipe)

    # Hard requirements (have to be met):
    if ignore:
        stmt = stmt.where(Recipe.id.not_in(ignore))

    if max_time_prep is not None:
        stmt = stmt.where(Recipe.time_prep <= max_time_prep)

    if max_time_total is not None:
        stmt = stmt.where(Recipe.time_total <= max_time_total)

    if tags:
        stmt = (
            stmt.join(Recipe.tags)
            .where(Tag.id.in_(tags))
            .group_by(Recipe.id)
            .having(func.count(Tag.id) >= len(tags))
        )

    candidates = list(db.scalars(stmt).unique())

    for c in candidates:
        recipe_data = (
            db.query(RecipeCooked).filter(RecipeCooked.recipe_id == c.id).first()
        )
        last_time_cooked = recipe_data.last_cooked if recipe_data is not None else None
        print("Score:", calculate_score(c, for_people, last_time_cooked))


def calculate_score(
    recipe: Recipe, for_people: list[int] | None, last_time_cooked: datetime | None
) -> float:
    AVG_RATING_MULTIPLIER = 2
    GROUP_MULTIPLIER = 3

    score = 1.0

    if len(recipe.ratings) > 0:
        avg = sum(r.stars for r in recipe.ratings) / len(recipe.ratings)
        score += avg * AVG_RATING_MULTIPLIER

    if for_people:
        ratings_found = [r.stars for r in recipe.ratings if r.user_id in for_people]

        if len(ratings_found) > 0:
            satisfaction = sum(ratings_found) / len(ratings_found)
            score += satisfaction * GROUP_MULTIPLIER

    if last_time_cooked is not None:
        delta = datetime.now(timezone.utc) - last_time_cooked
        print("Days:", delta)

    return score


if __name__ == "__main__":
    from database import SessionLocal, init_db

    init_db()

    with SessionLocal() as db:
        print("Output:", get_random_recipes(db))
