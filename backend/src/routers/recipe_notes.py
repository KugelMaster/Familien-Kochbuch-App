from fastapi import APIRouter
from starlette import status

from dependencies import DBDependency, UserDependency
from models import Recipe, RecipeNote
from schemas import Message, RecipeNoteCreate, RecipeNoteOut, RecipeNoteUpdate
from utils.http_exceptions import Forbidden, NotFound
from utils.statements import ensure_exists

router = APIRouter(prefix="/recipe-notes", tags=["RecipeNotes"])


@router.post("", response_model=RecipeNoteOut, status_code=status.HTTP_201_CREATED)
def create_recipe_note(
    recipe_note: RecipeNoteCreate, db: DBDependency, user: UserDependency
):
    ensure_exists(db, Recipe.id == recipe_note.recipe_id, NotFound("Recipe not found"))

    db_recipe_note = RecipeNote(
        recipe_id=recipe_note.recipe_id,
        user_id=user.user_id,
        content=recipe_note.content,
    )

    db.add(db_recipe_note)
    db.commit()
    db.refresh(db_recipe_note)

    return db_recipe_note


@router.get("/note/{note_id}", response_model=RecipeNoteOut)
def get_recipe_note(note_id: int, db: DBDependency):
    db_recipe_note = db.query(RecipeNote).filter(RecipeNote.id == note_id).first()

    if not db_recipe_note:
        raise NotFound("Recipe note not found")

    return db_recipe_note


@router.patch("/note/{note_id}", response_model=RecipeNoteOut)
def edit_recipe_note(
    note_id: int, patch: RecipeNoteUpdate, db: DBDependency, user: UserDependency
):
    db_recipe_note = db.query(RecipeNote).filter(RecipeNote.id == note_id).first()

    if not db_recipe_note:
        raise NotFound("Recipe note not found")

    if db_recipe_note.user_id != user.user_id and not user.is_admin:
        raise Forbidden(
            "Forbidden: You do not have permissions to edit this recipe note."
        )

    setattr(db_recipe_note, "content", patch.content)

    db.commit()
    db.refresh(db_recipe_note)

    return db_recipe_note


@router.delete("/note/{note_id}", response_model=Message)
def delete_recipe_note(note_id: int, db: DBDependency, user: UserDependency):
    db_recipe_note = db.query(RecipeNote).filter(RecipeNote.id == note_id).first()

    if not db_recipe_note:
        raise NotFound("Recipe note not found")

    if db_recipe_note.user_id != user.user_id and not user.is_admin:
        raise Forbidden(
            "Forbidden: You do not have permissions to delete this recipe note."
        )

    db.delete(db_recipe_note)
    db.commit()

    return Message(detail="Recipe note deleted successfully")


@router.get("/{recipe_id}", response_model=list[RecipeNoteOut])
def get_notes_for_recipe(recipe_id: int, db: DBDependency):
    ensure_exists(db, Recipe.id == recipe_id, NotFound("Recipe not found"))

    return db.query(RecipeNote).filter(RecipeNote.recipe_id == recipe_id).all()


@router.delete("/{recipe_id}", response_model=Message)
def delete_all_notes_from_recipe(
    recipe_id: int, db: DBDependency, user: UserDependency
):
    ensure_exists(db, Recipe.id == recipe_id, NotFound("Recipe not found"))

    if not user.is_admin:
        raise Forbidden(
            "Forbidden: You do not have permissions to delete all recipe notes of this recipe."
        )

    db.query(RecipeNote).filter(RecipeNote.recipe_id == recipe_id).delete()
    db.commit()

    return Message(detail="All notes for the recipe have been deleted successfully")
