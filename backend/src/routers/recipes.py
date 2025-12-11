from fastapi import APIRouter, Depends, UploadFile
from sqlalchemy.orm import Session
from database import SessionLocal
from schemas import RecipeCreate, RecipeOut, TagOut, UserNoteCreate, UserNoteOut, RatingCreate, RatingOut, RecipeUpdate
from crud import recipes, images

router = APIRouter(
    prefix="/recipes"
)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


####################################[Recipe]####################################
@router.post("", response_model=RecipeOut, tags=["Recipe"])
def create_recipe(recipe: RecipeCreate, db: Session = Depends(get_db)):
    return recipes.create_recipe(db, recipe)

@router.get("", response_model=list[RecipeOut], tags=["Recipe"])
def list_recipes(db: Session = Depends(get_db)):
    return recipes.get_recipes(db)

@router.get("/{recipe_id}", response_model=RecipeOut, tags=["Recipe"])
def get_recipe(recipe_id: int, db: Session = Depends(get_db)):
    return recipes.get_recipe(db, recipe_id)

@router.patch("/{recipe_id}", response_model=RecipeOut, tags=["Recipe"])
def update_recipe(recipe_id: int, patch: RecipeUpdate, db: Session = Depends(get_db)):
    return recipes.update_recipe(db, recipe_id, patch)

@router.delete("/{recipe_id}", response_model=dict, tags=["Recipe"])
def delete_recipe(recipe_id: int, db: Session = Depends(get_db)):
    return recipes.delete_recipe(db, recipe_id)


###################################[UserNote]###################################
@router.post("/usernote", response_model=UserNoteOut, tags=["UserNote"])
def create_usernote(usernote: UserNoteCreate, db: Session = Depends(get_db)):
    return recipes.create_usernote(db, usernote)

@router.get("/{recipe_id}/usernotes", response_model=list[UserNoteOut], tags=["UserNote"])
def list_usernotes(recipe_id: int, db: Session = Depends(get_db)):
    return recipes.get_usernotes(db, recipe_id)


####################################[Rating]####################################
@router.post("/rating", response_model=RatingOut, tags=["Rating"])
def create_rating(rating: RatingCreate, db: Session = Depends(get_db)):
    return recipes.create_rating(db, rating)

@router.get("/{recipe_id}/ratings", response_model=list[RatingOut], tags=["Rating"])
def list_ratings(recipe_id: int, db: Session = Depends(get_db)):
    return recipes.get_ratings(db, recipe_id)


####################################[Image]#####################################
@router.post("/{recipe_id}/image", response_model=dict, tags=["Image"])
def upload_recipe_image(recipe_id: int, file: UploadFile, db: Session = Depends(get_db)):
    return images.save_recipe_image(recipe_id, file, db)

@router.get("/{recipe_id}/image", tags=["Image"])
def get_recipe_image(recipe_id: int, db: Session = Depends(get_db)):
    return images.load_recipe_image(recipe_id, db)

#####################################[Tags]#####################################
@router.post("/tag", response_model=TagOut, tags=["Tag"])
def create_tag(tag_name: str, db: Session = Depends(get_db)):
    return recipes.create_tag(db, tag_name)

@router.get("/tags", response_model=list[TagOut], tags=["Tag"])
def list_tags(db: Session = Depends(get_db)):
    return recipes.get_tags(db)

@router.patch("/tags/{tag_id}", response_model=TagOut, tags=["Tag"])
def rename_tag(tag_id: int, new_name: str, db: Session = Depends(get_db)):
    return recipes.rename_tag(db, tag_id, new_name)

@router.delete("/tags/{tag_id}", response_model=dict, tags=["Tag"])
def delete_tag(tag_id: int, db: Session = Depends(get_db)):
    return recipes.delete_tag(db, tag_id)

# TODO: Function for sending all recipe ids associated with a tag