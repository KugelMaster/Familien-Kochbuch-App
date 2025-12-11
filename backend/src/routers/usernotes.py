from fastapi import APIRouter, Depends
from database import get_db
from sqlalchemy.orm import Session

from schemas import UserNoteCreate, UserNoteOut
from models import UserNote


router = APIRouter(
    prefix="/usernotes",
    tags=["UserNotes"]
)


@router.post("", response_model=UserNoteOut)
def create_usernote(usernote: UserNoteCreate, db: Session = Depends(get_db)):
    db_usernote = UserNote(
        recipe_id=usernote.recipe_id,
        user_id=usernote.user_id,
        text=usernote.text
    )

    db.add(db_usernote)
    db.commit()
    db.refresh(db_usernote)

    return db_usernote

@router.get("/{recipe_id}", response_model=list[UserNoteOut])
def list_usernotes(recipe_id: int, db: Session = Depends(get_db)):
    return db.query(UserNote).filter(UserNote.recipe_id == recipe_id).all()
