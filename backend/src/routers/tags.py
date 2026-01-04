from fastapi import APIRouter, Depends, HTTPException
from database import get_db
from sqlalchemy.orm import Session

from schemas import Message, RecipeOutSimple, TagOut
from models import Recipe, Tag
from utils.statements import recipe_simple_statement


router = APIRouter(
    prefix="/tags",
    tags=["Tags"]
)


@router.post("", response_model=TagOut)
def create_tag(tag_name: str, db: Session = Depends(get_db)):
    if db.query(Tag).filter(Tag.name == tag_name).first():
        raise HTTPException(status_code=400, detail="Tag with this name already exists")

    db_tag = Tag(name=tag_name)

    db.add(db_tag)
    db.commit()
    db.refresh(db_tag)

    return db_tag

@router.get("", response_model=list[TagOut])
def list_tags(db: Session = Depends(get_db)):
    return db.query(Tag).all()

@router.get("/{tag_id}", response_model=TagOut)
def get_tag(tag_id: int, db: Session = Depends(get_db)):
    tag = db.query(Tag).filter(Tag.id == tag_id).first()

    if not tag:
        raise HTTPException(status_code=404, detail="Tag not found")

    return tag

@router.patch("/{tag_id}", response_model=TagOut)
def rename_tag(tag_id: int, new_name: str, db: Session = Depends(get_db)):
    tag = db.query(Tag).filter(Tag.id == tag_id).first()

    if not tag:
        raise HTTPException(status_code=404, detail="Tag not found")

    setattr(tag, "name", new_name)
    db.commit()
    db.refresh(tag)

    return tag

@router.delete("/{tag_id}", response_model=Message)
def delete_tag(tag_id: int, db: Session = Depends(get_db)):
    tag = db.query(Tag).filter(Tag.id == tag_id).first()

    if not tag:
        raise HTTPException(status_code=404, detail="Tag not found")

    db.delete(tag)
    db.commit()

    return Message(detail="Tag deleted successfully")

@router.get("/{tag_id}/recipes", response_model=list[RecipeOutSimple])
def get_recipes_by_tag(tag_id: int, db: Session = Depends(get_db)):
    tag = db.query(Tag).filter(Tag.id == tag_id).first()

    if not tag:
        raise HTTPException(status_code=404, detail="Tag not found")

    stmt = recipe_simple_statement.where(Recipe.tags.any(Tag.id == tag_id))
    return db.execute(stmt).all()
