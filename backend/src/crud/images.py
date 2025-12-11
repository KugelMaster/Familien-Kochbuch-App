from fastapi import UploadFile, HTTPException
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
import shutil

from models import RecipeImage
from config import RECIPE_IMAGE_DIR

def save_recipe_image(recipe_id: int, file: UploadFile, db: Session) -> dict[str, str]:
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Only image files allowed")
    
    ext = file.content_type.split(".")[-1]
    filename = f"recipe_{recipe_id}.{ext}"
    file_path = RECIPE_IMAGE_DIR / filename

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    img = RecipeImage(
        recipe_id=recipe_id,
        filename=filename,
        file_path=str(file_path)
    )
    db.add(img)
    db.commit()

    return {"message": "uploaded", "filename": filename}

def load_recipe_image(recipe_id: int, db: Session):
    img = db.query(RecipeImage).filter(RecipeImage.recipe_id == recipe_id).first()

    if not img:
        raise HTTPException(status_code=404, detail="Image not found")
    
    return FileResponse(str(img.file_path))
