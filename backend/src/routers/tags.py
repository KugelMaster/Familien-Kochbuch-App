from fastapi import APIRouter, Depends, HTTPException
from database import SessionLocal
from sqlalchemy.orm import Session

from schemas import TagOut
from models import Tag


router = APIRouter(
    prefix="/tags",
    tags=["Tags"]
)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.post("", response_model=TagOut)
def create_tag(tag_name: str, db: Session = Depends(get_db)):
    db_tag = Tag(name=tag_name)

    db.add(db_tag)
    db.commit()
    db.refresh(db_tag)

    return db_tag

@router.get("", response_model=list[TagOut])
def list_tags(db: Session = Depends(get_db)):
    return db.query(Tag).all()

@router.patch("/{tag_id}", response_model=TagOut)
def rename_tag(tag_id: int, new_name: str, db: Session = Depends(get_db)):
    tag = db.query(Tag).filter(Tag.id == tag_id).first()

    if not tag:
        raise HTTPException(status_code=404, detail="Tag not found")

    setattr(tag, "name", new_name)
    db.commit()
    db.refresh(tag)

    return tag

@router.delete("/{tag_id}", response_model=dict)
def delete_tag(tag_id: int, db: Session = Depends(get_db)):
    tag = db.query(Tag).filter(Tag.id == tag_id).first()

    if not tag:
        raise HTTPException(status_code=404, detail="Tag not found")

    db.delete(tag)
    db.commit()

    return {"message": "deleted"}

# TODO: Function for sending all recipe ids associated with a tag
