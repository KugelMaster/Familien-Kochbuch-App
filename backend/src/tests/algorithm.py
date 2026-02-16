import sys
from datetime import datetime, timezone
from typing import Optional

sys.path.append(
    "C:\\Users\\Florian\\Documents\\GitHub\\Familien-Kochbuch-App\\backend\\src"
)

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from models import Recipe, RecipeCooked, Tag
from schemas import IngredientCreate as IngredientSchema
from schemas import NutritionCreate as NutritionSchema

# Konstanten für die Score-Berechnung
AVG_RATING_MULTIPLIER = 2.0
GROUP_MULTIPLIER = 3.0
MIN_LAST_TIME_COOKED_DAYS = 14.0
MAX_PENALTY_DAYS = 30.0

# TODO: Zukünftige Features
# - Ausbalancierte Nährstoffe
# - Benutzer-Vorlieben
# - Keine Wiederholung
# - Saisonalität


def get_random_recipes(
    db: Session,
    *,
    amount: int = 1,
    tags: Optional[list[int]] = None,
    max_time_prep: Optional[float] = None,
    max_time_total: Optional[float] = None,
    for_people: Optional[list[int]] = None,
    ignore: Optional[list[int]] = None,
    ingredients: Optional[list[IngredientSchema]] = None,
    nutritions: Optional[list[NutritionSchema]] = None,
) -> list[Recipe]:
    """
    Gets random recipes from the database based on filters and scores.

    Args:
        db (Session): Database session
        amount (int, optional): Number of recipes to return (may be less depending on filters)
        tags (list[int] | None, optional): List of tag IDs to filter by
        max_time_prep (float | None, optional): Maximum preparation time
        max_time_total (float | None, optional): Maximum total time
        for_people (list[int] | None, optional): List of user IDs for group satisfaction
        ignore (list[int] | None, optional): List of recipe IDs to ignore
        ingredients (list | None, optional): Available ingredients
        nutritions (list | None, optional): Required nutritions

    Returns:
        list[Recipe]: List of selected recipes, sorted by score
    """
    if amount < 1:
        raise ValueError("Amount must be at least 1")

    # Base query
    stmt = select(Recipe)

    ### Applying hard filters (have to be met) ###
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

    ### Fetching possible candidates ###
    candidates = list(db.scalars(stmt).unique())

    if not candidates:
        return []

    ### Filter by ingredients and nutritions (soft filters, but applied before scoring) ###
    if ingredients:
        candidates = filter_by_ingredients(candidates, ingredients)
    if nutritions:
        candidates = filter_by_nutritions(candidates, nutritions)

    if not candidates:
        return []

    # Batch query for last_cooked data (performance optimization)
    recipe_ids = [c.id for c in candidates]
    cooked_data = {
        rc.recipe_id: rc.last_cooked
        for rc in db.query(RecipeCooked)
        .filter(RecipeCooked.recipe_id.in_(recipe_ids))
        .all()
    }

    ### Calculate scores ###
    scored_candidates: list[tuple[float, Recipe]] = []
    for recipe in candidates:
        last_cooked = cooked_data.get(recipe.id)
        score = calculate_score(recipe, for_people, last_cooked)
        scored_candidates.append((score, recipe))

    ### Sort by score descending and return top-N ###
    scored_candidates.sort(key=lambda x: x[0], reverse=True)
    return [recipe for _, recipe in scored_candidates[:amount]]


def calculate_score(
    recipe: Recipe,
    for_people: Optional[list[int]],
    last_time_cooked: Optional[datetime],
) -> float:
    """
    Calculates the score for a recipe.

    Score components:
    - Average rating (biased multiplier)
    - Group satisfaction (biased multiplier)
    - Penalty for recently cooked recipes (exponental penalty)
    """
    score = 0.0

    # Average rating
    if recipe.ratings:
        avg_rating = sum(r.stars for r in recipe.ratings) / len(recipe.ratings)
        score += avg_rating * AVG_RATING_MULTIPLIER

    # Group satisfaction
    if for_people and recipe.ratings:
        group_ratings = [r.stars for r in recipe.ratings if r.user_id in for_people]
        if group_ratings:
            group_satisfaction = sum(group_ratings) / len(group_ratings)
            score += group_satisfaction * GROUP_MULTIPLIER

    # Penalty for recently cooked recipes
    if last_time_cooked is not None:
        days_since_cooked = (datetime.now(timezone.utc) - last_time_cooked).days
        if days_since_cooked < MIN_LAST_TIME_COOKED_DAYS:
            # Exponential penality, but capped
            penalty_factor = min(
                2 ** (MIN_LAST_TIME_COOKED_DAYS - days_since_cooked),
                2**MAX_PENALTY_DAYS,
            )
            score -= penalty_factor

    print(f"Recipe '{recipe.title}' - Score: {score:.2f}")
    return score


def filter_by_ingredients(
    candidates: list[Recipe],
    available_ingredients: list[IngredientSchema],
    tolerance: float = 0.05,
) -> list[Recipe]:
    """
    Filters recipes based on available ingredients.
    A recipe passes if all specified ingredients are in sufficient quantity (with tolerance).
    A recipe failes if it does not contain all available ingredients.
    """
    filtered: list[Recipe] = []
    for recipe in candidates:
        if all(
            any(
                avail.name.lower() == req.name.lower()
                and avail.unit == req.unit
                and (avail.amount or 0) >= (req.amount or 0) * (1 - tolerance)
                for req in recipe.ingredients
            )
            for avail in available_ingredients
        ):
            filtered.append(recipe)
    return filtered


def filter_by_nutritions(
    candidates: list[Recipe],
    required_nutritions: list[NutritionSchema],
    tolerance: float = 0.05,
) -> list[Recipe]:
    """
    Filters recipes based on required nutritions.
    A recipe passes if it meets all minimum nutrition requirements (with tolerance).
    """
    filtered: list[Recipe] = []
    for recipe in candidates:
        if all(
            any(
                avail.name.lower() == req.name.lower()
                and avail.unit == req.unit
                and (avail.amount or 0) >= (req.amount or 0) * (1 - tolerance)
                for avail in recipe.nutritions
            )
            for req in required_nutritions
        ):
            filtered.append(recipe)
    return filtered


if __name__ == "__main__":
    from mock_db import create_mock_session, create_recipes, load_json_fixture

    from schemas import RecipeCookedOut

    with create_mock_session() as db:
        create_recipes(db, "src/tests/mock_recipes.json")
        load_json_fixture(
            db, "src/tests/mock_analytics.json", RecipeCooked, RecipeCookedOut
        )

        recipes = get_random_recipes(
            db,
            amount=10,
            tags=[2],  # Mittagessen
            for_people=[2, 4, 5],  # 2=Florian, 3=Patricia, 4=Mama, 5=Papa
        )

        for r in recipes:
            print(r, end="\n" * 2)
