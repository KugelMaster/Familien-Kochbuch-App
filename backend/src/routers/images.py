from fastapi import APIRouter, Depends, UploadFile
from database import SessionLocal
from sqlalchemy.orm import Session

from crud import images


router = APIRouter(
    prefix="/images",
    tags=["Images"]
)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.post("/{recipe_id}", response_model=dict)
def upload_recipe_image(recipe_id: int, file: UploadFile, db: Session = Depends(get_db)):
    return images.save_recipe_image(recipe_id, file, db)

@router.get("/{recipe_id}")
def get_recipe_image(recipe_id: int, db: Session = Depends(get_db)):
    return images.load_recipe_image(recipe_id, db)
