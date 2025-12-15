from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from database import get_db
from sqlalchemy.orm import Session

from schemas import RecipeCreate, RecipeOutSimple, RecipeResponse, RecipeUpdate
from models import Image, Recipe, Ingredient, Nutrition, Tag


router = APIRouter(
    prefix="/recipes",
    tags=["Recipes"]
)


@router.post("", response_model=RecipeResponse)
def create_recipe(recipe: RecipeCreate, db: Session = Depends(get_db)):
    # Check if all tags exist
    db_tags = []
    if (tags := recipe.tags) is not None:
        db_tags = db.query(Tag).filter(Tag.id.in_(tags)).all()

        if len(db_tags) != len(tags):
            raise HTTPException(status_code=400, detail="One or more tags not found")
        
    if recipe.image_id is not None:
        img = db.query(Image).filter(Image.id == recipe.image_id).first()

        if not img:
            raise HTTPException(status_code=400, detail="Image not found")

    # If all conditions are met, create the recipe
    db_recipe = Recipe(
        title=recipe.title,
        image_id=recipe.image_id,
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

    if recipe.ingredients is not None:
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

@router.get("", response_model=list[RecipeResponse])
def list_recipes(db: Session = Depends(get_db)):
    return db.query(Recipe).order_by(Recipe.id).all()

@router.get("/simple", response_model=list[RecipeOutSimple])
def list_recipes_simple(db: Session = Depends(get_db)):
    return db.execute(select(Recipe.id, Recipe.title).order_by(Recipe.id)).all()

@router.get("/{recipe_id}", response_model=RecipeResponse)
def get_recipe(recipe_id: int, db: Session = Depends(get_db)):
    recipe = db.query(Recipe).filter(Recipe.id == recipe_id).first()

    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")

    return recipe

@router.patch("/{recipe_id}", response_model=RecipeResponse)
def update_recipe(recipe_id: int, patch: RecipeUpdate, db: Session = Depends(get_db)):
    recipe = db.query(Recipe).filter(Recipe.id == recipe_id).first()

    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")

    patch_data = patch.model_dump(exclude_unset=True)

    # Special handling for relationships:
    if "image_id" in patch_data:
        image_id = patch_data.pop("image_id")

        if image_id is not None:
            img = db.query(Image).filter(Image.id == image_id).first()

            if not img:
                raise HTTPException(status_code=400, detail="Image not found")
        
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

    if "tags" in patch_data:
        tag_ids = patch_data.pop("tags")

        new_tags = db.query(Tag).filter(Tag.id.in_(tag_ids)).all()

        if len(new_tags) != len(tag_ids):
            raise HTTPException(status_code=400, detail="One or more tags not found")
        
        recipe.tags = new_tags

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
