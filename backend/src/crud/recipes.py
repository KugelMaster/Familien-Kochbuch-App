from sqlalchemy.orm import Session

from models import Recipe, Ingredient, Nutrition, UserNote, Rating
from schemas import RecipeCreate, UserNoteCreate, RatingCreate

def create_recipe(db: Session, recipe: RecipeCreate) -> Recipe:
    db_recipe = Recipe(
        title=recipe.title,
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

def create_usernote(db: Session, usernote: UserNoteCreate) -> UserNote:
    db_usernote = UserNote(
        recipe_id=usernote.recipe_id,
        user_id=usernote.user_id,
        text=usernote.text
    )

    db.add(db_usernote)
    db.commit()
    db.refresh(db_usernote)

    return db_usernote

def create_rating(db: Session, rating: RatingCreate) -> Rating:
    db_rating = Rating(
        recipe_id=rating.recipe_id,
        user_id=rating.user_id,
        stars=rating.stars,
        comment=rating.comment
    )

    db.add(db_rating)
    db.commit()
    db.refresh(db_rating)

    return db_rating

def get_recipes(db: Session) -> list[Recipe]:
    return db.query(Recipe).all()

def get_usernotes(db: Session, recipe_id: int) -> list[UserNote]:
    return db.query(UserNote).filter(UserNote.recipe_id == recipe_id).all()

def get_ratings(db: Session, recipe_id: int) -> list[Rating]:
    return db.query(Rating).filter(Rating.recipe_id == recipe_id).all()
