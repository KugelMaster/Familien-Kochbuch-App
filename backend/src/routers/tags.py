from fastapi import APIRouter
from starlette import status

from dependencies import DBDependency
from models import Recipe, Tag
from schemas import ErrorCode, Message, RecipeOutSimple, TagOut
from utils.http_exceptions import BadRequest, NotFound
from utils.statements import ensure_exists, recipe_simple_statement

router = APIRouter(prefix="/tags", tags=["Tags"])


@router.post("", response_model=TagOut, status_code=status.HTTP_201_CREATED)
def create_tag(tag_name: str, db: DBDependency):
    if db.query(Tag).filter(Tag.name == tag_name).first():
        raise BadRequest("Tag with this name already exists", code=ErrorCode.EXISTS)

    db_tag = Tag(name=tag_name)

    db.add(db_tag)
    db.commit()
    db.refresh(db_tag)

    return db_tag


@router.get("", response_model=list[TagOut])
def list_tags(db: DBDependency):
    return db.query(Tag).all()


@router.get("/{tag_id}", response_model=TagOut)
def get_tag(tag_id: int, db: DBDependency):
    tag = db.query(Tag).filter(Tag.id == tag_id).first()

    if not tag:
        raise NotFound("Tag not found")

    return tag


@router.patch("/{tag_id}", response_model=TagOut)
def rename_tag(tag_id: int, new_name: str, db: DBDependency):
    tag = db.query(Tag).filter(Tag.id == tag_id).first()

    if not tag:
        raise NotFound("Tag not found")

    setattr(tag, "name", new_name)
    db.commit()
    db.refresh(tag)

    return tag


@router.delete("/{tag_id}", response_model=Message)
def delete_tag(tag_id: int, db: DBDependency):
    tag = db.query(Tag).filter(Tag.id == tag_id).first()

    if not tag:
        raise NotFound("Tag not found")

    db.delete(tag)
    db.commit()

    return Message(detail="Tag deleted successfully")


@router.get("/{tag_id}/recipes", response_model=list[RecipeOutSimple])
def get_recipes_by_tag(tag_id: int, db: DBDependency):
    ensure_exists(db, Tag.id == tag_id, NotFound("Tag not found"))

    stmt = recipe_simple_statement.where(Recipe.tags.any(Tag.id == tag_id))
    return db.execute(stmt).all()
