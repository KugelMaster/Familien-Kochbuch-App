from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class IngredientCreate(BaseModel):
    name: str
    amount: Optional[str] = None
    unit: Optional[str] = None

class NutritionCreate(BaseModel):
    name: str
    amount: Optional[str] = None
    unit: Optional[str] = None

class UserNoteCreate(BaseModel):
    recipe_id: int
    user_id: int
    text: str

class RatingCreate(BaseModel):
    recipe_id: int
    user_id: int
    stars: float # Zwischen 0 und 5 mit 0,5 Schritten
    comment: Optional[str] = None

class RecipeCreate(BaseModel):
    title: str
    description: Optional[str] = None
    time_prep: Optional[float] = None
    time_total: Optional[float] = None
    portions: float = 1.0
    recipe_url: Optional[str] = None

    ingredients: list[IngredientCreate]
    nutritions: Optional[list[NutritionCreate]] = None # Vllt. später automatisch aus Zutaten berechnen?


class UserNoteOut(UserNoteCreate):
    id: int
    created_at: datetime
    updated_at: datetime

class RatingOut(RatingCreate):
    id: int
    created_at: datetime
    updated_at: datetime

class RecipeOut(RecipeCreate):
    """Ratings sind mit dem Rezept durch eine eigene gespeicherte ID zum Rezept verbunden, daher werden sie nicht in der RecipeOut Klasse angegeben."""
    id: int
    user_notes: list[UserNoteCreate] = []

    created_at: datetime
    updated_at: datetime

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

class User(BaseModel):
    id: UUID
    name: str
    #email: str
    avatar_url: str
    created_at: str
    updated_at: str
"""