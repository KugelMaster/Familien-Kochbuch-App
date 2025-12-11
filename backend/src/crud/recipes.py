from fastapi import HTTPException
from sqlalchemy.orm import Session

from models import Recipe, Ingredient, Nutrition, UserNote, Rating, Tag, RecipeTag
from schemas import RecipeCreate, UserNoteCreate, RatingCreate, RecipeUpdate

####################################[Recipe]####################################
def create_recipe(db: Session, recipe: RecipeCreate) -> Recipe:
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

def get_recipes(db: Session) -> list[Recipe]:
    return db.query(Recipe).all()

def get_recipe(db: Session, recipe_id: int) -> Recipe | None:
    return db.query(Recipe).filter(Recipe.id == recipe_id).first()

def update_recipe(db: Session, recipe_id: int, patch: RecipeUpdate) -> Recipe | None:
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

def delete_recipe(db: Session, recipe_id: int) -> dict[str, str]:
    recipe = db.query(Recipe).filter(Recipe.id == recipe_id).first()

    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")

    db.delete(recipe)
    db.commit()

    return {"message": "deleted"}


###################################[UserNote]###################################
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

def get_usernotes(db: Session, recipe_id: int) -> list[UserNote]:
    return db.query(UserNote).filter(UserNote.recipe_id == recipe_id).all()


####################################[Rating]####################################
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

def get_ratings(db: Session, recipe_id: int) -> list[Rating]:
    return db.query(Rating).filter(Rating.recipe_id == recipe_id).all()


#####################################[Tags]#####################################
def create_tag(db: Session, name: str) -> Tag:
    db_tag = Tag(name=name)

    db.add(db_tag)
    db.commit()
    db.refresh(db_tag)

    return db_tag

def get_tags(db: Session) -> list[Tag]:
    return db.query(Tag).all()

def rename_tag(db: Session, tag_id: int, new_name: str) -> Tag | None:
    tag = db.query(Tag).filter(Tag.id == tag_id).first()

    if not tag:
        raise HTTPException(status_code=404, detail="Tag not found")

    setattr(tag, "name", new_name)
    db.commit()
    db.refresh(tag)

    return tag

def delete_tag(db: Session, tag_id: int) -> dict[str, str]:
    tag = db.query(Tag).filter(Tag.id == tag_id).first()

    if not tag:
        raise HTTPException(status_code=404, detail="Tag not found")

    db.delete(tag)
    db.commit()

    return {"message": "deleted"}
