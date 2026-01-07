from fastapi import APIRouter
from starlette import status

from dependencies import db_dependency
from models import Recipe, RecipeNote, User
from schemas import Message, RecipeNoteCreate, RecipeNoteOut, RecipeNoteUpdate
from utils.http_exceptions import NotFound
from utils.statements import ensure_exists

router = APIRouter(prefix="/recipe-notes", tags=["RecipeNotes"])


@router.post("", response_model=RecipeNoteOut, status_code=status.HTTP_201_CREATED)
def create_recipe_note(recipe_note: RecipeNoteCreate, db: db_dependency):
    ensure_exists(db, Recipe.id == recipe_note.recipe_id, NotFound("Recipe not found"))
    ensure_exists(db, User.id == recipe_note.user_id, NotFound("User not found"))

    db_recipe_note = RecipeNote(
        recipe_id=recipe_note.recipe_id,
        user_id=recipe_note.user_id,
        content=recipe_note.content,
    )

    db.add(db_recipe_note)
    db.commit()
    db.refresh(db_recipe_note)

    return db_recipe_note


@router.get("/note/{note_id}", response_model=RecipeNoteOut)
def get_recipe_note(note_id: int, db: db_dependency):
    db_recipe_note = db.query(RecipeNote).filter(RecipeNote.id == note_id).first()

    if not db_recipe_note:
        raise NotFound("Recipe note not found")

    return db_recipe_note


@router.patch("/note/{note_id}", response_model=RecipeNoteOut)
def edit_recipe_note(note_id: int, patch: RecipeNoteUpdate, db: db_dependency):
    db_recipe_note = db.query(RecipeNote).filter(RecipeNote.id == note_id).first()

    if not db_recipe_note:
        raise NotFound("Recipe note not found")

    setattr(db_recipe_note, "content", patch.content)

    db.commit()
    db.refresh(db_recipe_note)

    return db_recipe_note


@router.delete("/note/{note_id}", response_model=Message)
def delete_recipe_note(note_id: int, db: db_dependency):
    db_recipe_note = db.query(RecipeNote).filter(RecipeNote.id == note_id).first()

    if not db_recipe_note:
        raise NotFound("Recipe note not found")

    db.delete(db_recipe_note)
    db.commit()

    return Message(detail="Recipe note deleted successfully")


@router.get("/{recipe_id}", response_model=list[RecipeNoteOut])
def get_notes_for_recipe(recipe_id: int, db: db_dependency):
    ensure_exists(db, Recipe.id == recipe_id, NotFound("Recipe not found"))

    return db.query(RecipeNote).filter(RecipeNote.recipe_id == recipe_id).all()


@router.delete("/{recipe_id}", response_model=Message)
def delete_all_notes_from_recipe(recipe_id: int, db: db_dependency):
    ensure_exists(db, Recipe.id == recipe_id, NotFound("Recipe not found"))

    db.query(RecipeNote).filter(RecipeNote.recipe_id == recipe_id).delete()
    db.commit()

    return Message(detail="All notes for the recipe have been deleted successfully")
