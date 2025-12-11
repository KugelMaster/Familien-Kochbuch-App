from fastapi import APIRouter, Depends, HTTPException
from database import SessionLocal
from sqlalchemy.orm import Session

from schemas import RecipeCreate, RecipeOut, RecipeUpdate
from models import Recipe, Ingredient, Nutrition, Tag, RecipeTag


router = APIRouter(
    prefix="/recipes",
    tags=["Recipes"]
)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.post("", response_model=RecipeOut)
def create_recipe(recipe: RecipeCreate, db: Session = Depends(get_db)):
    db_recipe = Recipe(
        title=recipe.title,
        image=recipe.image,
        description=recipe.description,
        time_prep=recipe.time_prep,
        time_total=recipe.time_total,
        portions=recipe.portions,
        recipe_url=recipe.recipe_url
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

    ### Optional stuff ###
    if recipe.tags is not None:
        for name in recipe.tags:
            db_tag = Tag(name=name)
            db.add(db_tag)
            db.commit()
            db.refresh(db_tag)

            db.add(RecipeTag(
                recipe_id=db_recipe.id,
                tag_id=db_tag.id
            ))

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
    return db.query(Recipe).all()

@router.get("/{recipe_id}", response_model=RecipeOut)
def get_recipe(recipe_id: int, db: Session = Depends(get_db)):
    return db.query(Recipe).filter(Recipe.id == recipe_id).first()

@router.patch("/{recipe_id}", response_model=RecipeOut)
def update_recipe(recipe_id: int, patch: RecipeUpdate, db: Session = Depends(get_db)):
    recipe = db.query(Recipe).filter(Recipe.id == recipe_id).first()

    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")

    patch_data = patch.model_dump(exclude_unset=True)

    # Special handling for tags:
    if "tags" in patch_data:
        tag_ids = patch_data.pop("tags")

        new_tags = db.query(Tag).filter(Tag.id.in_(tag_ids)).all()

        if len(new_tags) != len(tag_ids):
            raise HTTPException(status_code=400, detail="One or more tags not found")
        
        recipe.tags = new_tags

    # Update normal fields
    for key, value in patch_data.items():
        setattr(recipe, key, value)

    print(recipe.tags)

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
