import shutil
import uuid

from fastapi import APIRouter, Form, UploadFile
from fastapi.responses import FileResponse
from starlette import status

from config import config
from dependencies import DBDependency, OptionalUserDep
from models import Image
from schemas import ErrorCode, ImageTag, ImageUploadResponse, Message
from utils.http_exceptions import BadRequest, InternalServerError, NotFound

router = APIRouter(prefix="/images", tags=["Images"])


@router.post(
    "", response_model=ImageUploadResponse, status_code=status.HTTP_201_CREATED
)
def upload_image(
    file: UploadFile, db: DBDependency, user: OptionalUserDep, tag: ImageTag = Form(...)
):
    if not file.content_type or not file.content_type.startswith("image/"):
        raise BadRequest("Only image files allowed", code=ErrorCode.INVALID_FORMAT)

    user_id = None if user is None else user.user_id

    ext = file.content_type.split("/")[-1]
    filename = f"{uuid.uuid4()}.{ext}"
    file_path = config.IMAGE_DIR_RECIPES / filename

    with open(file_path, "xb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    img = Image(
        filename=filename, file_path=str(file_path), tag=tag, uploaded_by=user_id
    )
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

    try:
        file_path = config.IMAGE_DIR_RECIPES / img.filename
        file_path.unlink()
    except Exception as e:
        print(f"Error deleting image file: {e}")
        raise InternalServerError("Error deleting image file")

    db.delete(img)
    db.commit()

    return Message(detail="Image deleted successfully")
