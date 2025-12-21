from fastapi import APIRouter, Depends, HTTPException
from database import get_db
from sqlalchemy.orm import Session

from schemas import RecipeNoteCreate, RecipeNoteOut, RecipeNoteUpdate
from models import RecipeNote


router = APIRouter(
    prefix="/recipe-notes",
    tags=["RecipeNotes"]
)


@router.post("", response_model=RecipeNoteOut)
def create_recipe_note(recipe_note: RecipeNoteCreate, db: Session = Depends(get_db)):
    db_recipe_note = RecipeNote(
        recipe_id=recipe_note.recipe_id,
        user_id=recipe_note.user_id,
        content=recipe_note.content
    )

    db.add(db_recipe_note)
    db.commit()
    db.refresh(db_recipe_note)

    return db_recipe_note

@router.get("/{note_id}", response_model=RecipeNoteOut)
def get_recipe_note(note_id: int, db: Session = Depends(get_db)):
    db_recipe_note = db.query(RecipeNote).filter(RecipeNote.id == note_id).first()

    if not db_recipe_note:
        raise HTTPException(status_code=404, detail="Recipe note not found")
    
    return db_recipe_note

@router.patch("/{note_id}", response_model=RecipeNoteOut)
def edit_recipe_note(note_id: int, patch: RecipeNoteUpdate, db: Session = Depends(get_db)):
    db_recipe_note = db.query(RecipeNote).filter(RecipeNote.id == note_id).first()

    if not db_recipe_note:
        raise HTTPException(status_code=404, detail="Recipe note not found")
    
    setattr(db_recipe_note, "content", patch.content)

    db.commit()
    db.refresh(db_recipe_note)

    return db_recipe_note

@router.delete("/{note_id}", response_model=dict)
def delete_recipe_note(note_id: int, db: Session = Depends(get_db)):
    db_recipe_note = db.query(RecipeNote).filter(RecipeNote.id == note_id).first()

    if not db_recipe_note:
        raise HTTPException(status_code=404, detail="Recipe note not found")
    
    db.delete(db_recipe_note)
    db.commit()

    return {"detail": "Recipe note deleted"}
