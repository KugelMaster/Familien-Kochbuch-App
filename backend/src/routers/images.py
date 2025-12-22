from fastapi import APIRouter, Depends, UploadFile, HTTPException
from fastapi.responses import FileResponse
from database import get_db
from sqlalchemy.orm import Session
import shutil
import uuid

from models import Image
from config import RECIPE_IMAGE_DIR
from schemas import ImageUploadResponse, Message


router = APIRouter(
    prefix="/images",
    tags=["Images"]
)


@router.post("", response_model=ImageUploadResponse)
def upload_image(file: UploadFile, db: Session = Depends(get_db)):
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
    db.refresh(img)

    return img

@router.get("/filename/{filename}", response_class=FileResponse)
def get_image_by_filename(filename: str, db: Session = Depends(get_db)):
    img = db.query(Image).filter(Image.filename == filename).first()

    if not img:
        raise HTTPException(status_code=404, detail="Image not found")
    
    return FileResponse(str(img.file_path))

@router.get("/{image_id}", response_class=FileResponse)
def get_image_by_id(image_id: int, db: Session = Depends(get_db)):
    img = db.query(Image).filter(Image.id == image_id).first()

    if not img:
        raise HTTPException(status_code=404, detail="Image not found")
    
    return FileResponse(str(img.file_path))

@router.delete("/{image_id}", response_model=Message)
def delete_image(image_id: int, db: Session = Depends(get_db)):
    img = db.query(Image).filter(Image.id == image_id).first()

    if not img:
        raise HTTPException(status_code=404, detail="Image not found")
    
    # Delete the file from the filesystem
    try:
        file_path = RECIPE_IMAGE_DIR / img.filename
        file_path.unlink()
    except Exception as e:
        print(f"Error deleting image file: {e}")
        raise HTTPException(status_code=500, detail="Error deleting image file")

    # Delete the database record
    db.delete(img)
    db.commit()

    return Message(detail="Image deleted successfully")
