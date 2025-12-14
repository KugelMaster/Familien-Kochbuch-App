from fastapi import APIRouter, Depends, HTTPException
from database import get_db
from sqlalchemy.orm import Session

from schemas import RecipeCreate, RecipeOut, RecipeUpdate
from models import Recipe, Ingredient, Nutrition, Tag


router = APIRouter(
    prefix="/recipes",
    tags=["Recipes"]
)


@router.post("", response_model=RecipeOut)
def create_recipe(recipe: RecipeCreate, db: Session = Depends(get_db)):
    # Check if all tags exist
    db_tags = []
    if (tags := recipe.tags) is not None:
        db_tags = db.query(Tag).filter(Tag.id.in_(tags)).all()

        if len(db_tags) != len(tags):
            raise HTTPException(status_code=400, detail="One or more tags not found")

    # If all conditions are met, create the recipe
    db_recipe = Recipe(
        title=recipe.title,
        image=recipe.image,
        description=recipe.description,
        time_prep=recipe.time_prep,
        time_total=recipe.time_total,
        portions=recipe.portions,
        recipe_uri=recipe.recipe_uri,
        tags=db_tags
    )

    db.add(db_recipe)
    db.commit()
    db.refresh(db_recipe)

    for ingredient in recipe.ingredients:
        db_ingredient = Ingredient(
            recipe_id=db_recipe.id,
            name=ingredient.name,
            amount=ingredient.amount,
            unit=ingredient.unit
        )
        db.add(db_ingredient)

    if recipe.nutritions is not None:
        for nutrition in recipe.nutritions:
            db_nutrition = Nutrition(
                recipe_id=db_recipe.id,
                name=nutrition.name,
                amount=nutrition.amount,
                unit=nutrition.unit
            )
            db.add(db_nutrition)    

    db.commit()
    return db_recipe

@router.get("", response_model=list[RecipeOut])
def list_recipes(db: Session = Depends(get_db)):
    return db.query(Recipe).order_by(Recipe.id).all()

@router.get("/{recipe_id}", response_model=RecipeOut)
def get_recipe(recipe_id: int, db: Session = Depends(get_db)):
    return db.query(Recipe).filter(Recipe.id == recipe_id).first()

@router.patch("/{recipe_id}", response_model=RecipeOut)
def update_recipe(recipe_id: int, patch: RecipeUpdate, db: Session = Depends(get_db)):
    recipe = db.query(Recipe).filter(Recipe.id == recipe_id).first()

    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")

    patch_data = patch.model_dump(exclude_unset=True)

    # Special handling for relationships:
    if "tags" in patch_data:
        tag_ids = patch_data.pop("tags")

        new_tags = db.query(Tag).filter(Tag.id.in_(tag_ids)).all()

        if len(new_tags) != len(tag_ids):
            raise HTTPException(status_code=400, detail="One or more tags not found")
        
        recipe.tags = new_tags

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
                unit=ingredient_data.get("unit", None)
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
                unit=nutrition_data.get("unit", None)
            )
            db.add(db_nutrition)

    # Update normal fields
    for key, value in patch_data.items():
        setattr(recipe, key, value)

    db.commit()
    db.refresh(recipe)

    return recipe

@router.delete("/{recipe_id}", response_model=dict)
def delete_recipe(recipe_id: int, db: Session = Depends(get_db)):
    recipe = db.query(Recipe).filter(Recipe.id == recipe_id).first()

    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")

    db.delete(recipe)
    db.commit()

    return {"message": "deleted"}
