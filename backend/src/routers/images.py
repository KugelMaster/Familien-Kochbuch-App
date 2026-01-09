import shutil
import uuid

from fastapi import APIRouter, UploadFile
from fastapi.responses import FileResponse
from starlette import status

from config import RECIPE_IMAGE_DIR
from dependencies import DBDependency
from models import Image
from schemas import ImageUploadResponse, Message
from utils.http_exceptions import BadRequest, InternalServerError, NotFound

router = APIRouter(prefix="/images", tags=["Images"])


@router.post(
    "", response_model=ImageUploadResponse, status_code=status.HTTP_201_CREATED
)
def upload_image(file: UploadFile, db: DBDependency):
    if not file.content_type or not file.content_type.startswith("image/"):
        raise BadRequest("Only image files allowed")

    ext = file.content_type.split("/")[-1]
    filename = f"{uuid.uuid4()}.{ext}"
    file_path = RECIPE_IMAGE_DIR / filename

    with open(file_path, "xb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    img = Image(filename=filename, file_path=str(file_path))
    db.add(img)
    db.commit()
    db.refresh(img)

    return img


@router.get("/filename/{filename}", response_class=FileResponse)
def get_image_by_filename(filename: str, db: DBDependency):
    img = db.query(Image).filter(Image.filename == filename).first()

    if not img:
        raise NotFound("Image not found")

    return FileResponse(str(img.file_path))


@router.get("/{image_id}", response_class=FileResponse)
def get_image_by_id(image_id: int, db: DBDependency):
    img = db.query(Image).filter(Image.id == image_id).first()

    if not img:
        raise NotFound("Image not found")

    return FileResponse(str(img.file_path))


@router.delete("/{image_id}", response_model=Message)
def delete_image(image_id: int, db: DBDependency):
    img = db.query(Image).filter(Image.id == image_id).first()

    if not img:
        raise NotFound("Image not found")

    # Delete the file from the filesystem
    try:
        file_path = RECIPE_IMAGE_DIR / img.filename
        file_path.unlink()
    except Exception as e:
        print(f"Error deleting image file: {e}")
        raise InternalServerError("Error deleting image file")

    # Delete the database record
    db.delete(img)
    db.commit()

    return Message(detail="Image deleted successfully")
