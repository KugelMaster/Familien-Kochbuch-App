from sqlalchemy.orm import Session
import models, schemas


def create_recipe(db: Session, recipe: schemas.RecipeCreate) -> models.Recipe:
    db_recipe = models.Recipe(title=recipe.title, description=recipe.description)
    db.add(db_recipe)
    db.commit()
    db.refresh(db_recipe)

    for ingredient in recipe.ingredients:
        db_ingredient = models.Ingredient(
            recipe_id=db_recipe.id,
            name=ingredient.name,
            amount=ingredient.amount,
            unit=ingredient.unit
        )
        db.add(db_ingredient)

    db.commit()
    return db_recipe

def get_recipes(db: Session) -> list[models.Recipe]:
    return db.query(models.Recipe).all()
