from fastapi import APIRouter, Depends, Request, UploadFile, HTTPException
from fastapi.responses import FileResponse
from database import get_db
from sqlalchemy.orm import Session
import shutil
import uuid

from models import Image
from config import RECIPE_IMAGE_DIR


router = APIRouter(
    prefix="/images",
    tags=["Images"]
)


@router.post("", response_model=str)
def upload_image(file: UploadFile, request: Request, db: Session = Depends(get_db)):
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Only image files allowed")

    ext = file.content_type.split("/")[-1]
    filename = f"{uuid.uuid4()}.{ext}"
    file_path = RECIPE_IMAGE_DIR / filename

    with open(file_path, "xb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    img = Image(
        filename=filename,
        file_path=str(file_path)
    )
    db.add(img)
    db.commit()

    return filename

@router.get("/{filename}")
def get_recipe_image(filename: str, db: Session = Depends(get_db)):
    img = db.query(Image).filter(Image.filename == filename).first()

    if not img:
        raise HTTPException(status_code=404, detail="Image not found")
    
    return FileResponse(str(img.file_path))
