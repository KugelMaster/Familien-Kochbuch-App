from pydantic import BaseModel
from typing import Optional


class IngredientCreate(BaseModel):
    name: str
    amount: Optional[str] = None
    unit: Optional[str] = None

class RecipeCreate(BaseModel):
    title: str
    description: Optional[str] = None
    ingredients: list[IngredientCreate]

class RecipeOut(BaseModel):
    id: int
    title: str
    description: Optional[str]
    ingredients: list[IngredientCreate]

    class Config:
        from_attributes = True

"""
class RecipeImages(BaseModel):
    id: UUID
    recipe_id: UUID
    url: str # Backend-URL des Bildes
    uploaded_by: UUID
    created_at: str
    updated_at: str

class Ratings(BaseModel):
    id: UUID
    recipe_id: UUID
    user_id: UUID
    stars: int #0 - 5 mit 0,5 Schritten
    comment: str
    created_at: str
    updated_at: str

class UserNote(BaseModel):
    id: UUID
    recipe_id: UUID
    user_id: UUID
    text: str
    created_at: str
    updated_at: str

class User(BaseModel):
    id: UUID
    name: str
    #email: str
    avatar_url: str
    created_at: str
    updated_at: str
"""