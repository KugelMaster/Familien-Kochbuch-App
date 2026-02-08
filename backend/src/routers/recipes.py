from fastapi import APIRouter
from starlette import status

from dependencies import DBDependency
from models import Image, Ingredient, Nutrition, Recipe, Tag
from schemas import (
    ErrorCode,
    Message,
    RecipeCreate,
    RecipeOutSimple,
    RecipeResponse,
    RecipeUpdate,
)
from utils.http_exceptions import BadRequest, NotFound
from utils.statements import ensure_exists, recipe_simple_statement

router = APIRouter(prefix="/recipes", tags=["Recipes"])


@router.post("", response_model=RecipeResponse, status_code=status.HTTP_201_CREATED)
def create_recipe(recipe: RecipeCreate, db: DBDependency):
    # Check if all tags exist
    db_tags = []
    if (tags := recipe.tags) is not None:
        db_tags = db.query(Tag).filter(Tag.id.in_(tags)).all()

        if len(db_tags) != len(tags):
            raise BadRequest("One or more tags not found", code=ErrorCode.NOT_FOUND)

    if recipe.image_id is not None:
        ensure_exists(
            db,
            Image.id == recipe.image_id,
            BadRequest("Image not found", code=ErrorCode.NOT_FOUND),
        )

    if recipe.recipe_uri is not None and recipe.recipe_uri.strip() == "":
        recipe.recipe_uri = None

    # If all conditions are met, create the recipe
    db_recipe = Recipe(
        title=recipe.title,
        image_id=recipe.image_id,
        description=recipe.description,
        time_prep=recipe.time_prep,
        time_total=recipe.time_total,
        portions=recipe.portions,
        recipe_uri=recipe.recipe_uri,
        tags=db_tags,
    )

    db.add(db_recipe)
    db.commit()
    db.refresh(db_recipe)

    if recipe.ingredients is not None:
        for ingredient in recipe.ingredients:
            db_ingredient = Ingredient(
                recipe_id=db_recipe.id,
                name=ingredient.name,
                amount=ingredient.amount,
                unit=ingredient.unit,
            )
            db.add(db_ingredient)

    if recipe.nutritions is not None:
        for nutrition in recipe.nutritions:
            db_nutrition = Nutrition(
                recipe_id=db_recipe.id,
                name=nutrition.name,
                amount=nutrition.amount,
                unit=nutrition.unit,
            )
            db.add(db_nutrition)

    db.commit()
    return db_recipe


@router.get("", response_model=list[RecipeResponse])
def list_recipes(db: DBDependency):
    return db.query(Recipe).order_by(Recipe.id).all()


@router.get("/simple", response_model=list[RecipeOutSimple])
def list_recipes_simple(db: DBDependency):
    return db.execute(recipe_simple_statement).all()


@router.get("/{recipe_id}", response_model=RecipeResponse)
def get_recipe(recipe_id: int, db: DBDependency):
    recipe = db.query(Recipe).filter(Recipe.id == recipe_id).first()

    if not recipe:
        raise NotFound("Recipe not found")

    return recipe


@router.patch("/{recipe_id}", response_model=RecipeResponse)
def update_recipe(recipe_id: int, patch: RecipeUpdate, db: DBDependency):
    recipe = db.query(Recipe).filter(Recipe.id == recipe_id).first()

    if not recipe:
        raise NotFound("Recipe not found")

    patch_data = patch.model_dump(exclude_unset=True)

    # Special handling for relationships:
    if "image_id" in patch_data:
        image_id = patch_data.pop("image_id")

        if image_id is not None:
            ensure_exists(
                db,
                Image.id == image_id,
                BadRequest("Image not found", code=ErrorCode.NOT_FOUND),
            )

        recipe.image_id = image_id

    if "ingredients" in patch_data:
        ingredient_dicts = patch_data.pop("ingredients")

        # Delete existing ingredients
        db.query(Ingredient).filter(Ingredient.recipe_id == recipe.id).delete()

        # Add new ingredients
        for ingredient_data in ingredient_dicts:
            db_ingredient = Ingredient(
                recipe_id=recipe.id,
                name=ingredient_data.get("name", ""),
                amount=ingredient_data.get("amount", None),
                unit=ingredient_data.get("unit", None),
            )
            db.add(db_ingredient)

    if "nutritions" in patch_data:
        nutrition_dicts = patch_data.pop("nutritions")

        # Delete existing nutritions
        db.query(Nutrition).filter(Nutrition.recipe_id == recipe.id).delete()

        # Add new nutritions
        for nutrition_data in nutrition_dicts:
            db_nutrition = Nutrition(
                recipe_id=recipe.id,
                name=nutrition_data.get("name", ""),
                amount=nutrition_data.get("amount", None),
                unit=nutrition_data.get("unit", None),
            )
            db.add(db_nutrition)

    if "tags" in patch_data:
        tag_ids = patch_data.pop("tags")

        new_tags = db.query(Tag).filter(Tag.id.in_(tag_ids)).all()

        if len(new_tags) != len(tag_ids):
            raise BadRequest("One or more tags not found", code=ErrorCode.NOT_FOUND)

        recipe.tags = new_tags

    # Update normal fields
    for key, value in patch_data.items():
        setattr(recipe, key, value)

    db.commit()
    db.refresh(recipe)

    return recipe


@router.delete("/{recipe_id}", response_model=Message)
def delete_recipe(recipe_id: int, db: DBDependency):
    recipe = db.query(Recipe).filter(Recipe.id == recipe_id).first()

    if not recipe:
        raise NotFound("Recipe not found")

    db.delete(recipe)
    db.commit()

    return Message(detail="Recipe deleted successfully")
