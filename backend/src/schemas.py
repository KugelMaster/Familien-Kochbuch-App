from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class TagCreate(BaseModel):
    name: str

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
    tags: Optional[list[int]] = None
    image: Optional[str] = None
    description: Optional[str] = None
    time_prep: Optional[float] = None
    time_total: Optional[float] = None
    portions: float = 1.0
    recipe_url: Optional[str] = None

    ingredients: list[IngredientCreate]
    nutritions: Optional[list[NutritionCreate]] = None # Vllt. später automatisch aus Zutaten berechnen?

class TagOut(BaseModel):
    id: int
    name: str

class UserNoteOut(BaseModel):
    id: int
    user_id: int
    text: str

    created_at: Optional[datetime]
    updated_at: Optional[datetime]

class RatingOut(BaseModel):
    id: int
    user_id: int
    stars: float # Zwischen 0 und 5 mit 0,5 Schritten
    comment: Optional[str] = None

    created_at: Optional[datetime]
    updated_at: Optional[datetime]

class RecipeOut(BaseModel):
    id: int
    title: str
    tags: Optional[list[TagOut]] = None
    image: Optional[str] = None
    description: Optional[str] = None
    time_prep: Optional[float] = None
    time_total: Optional[float] = None
    portions: float = 1.0
    recipe_url: Optional[str] = None

    ingredients: list[IngredientCreate]
    nutritions: Optional[list[NutritionCreate]] = None # Vllt. später automatisch aus Zutaten berechnen?
    user_notes: Optional[list[UserNoteOut]] = None
    ratings: Optional[list[RatingOut]] = None

    created_at: Optional[datetime]
    updated_at: Optional[datetime]

    class Config:
        from_attributes = True


class RecipeUpdate(BaseModel):
    title: Optional[str] = None
    tags: Optional[list[int]] = None
    image: Optional[str] = None
    description: Optional[str] = None
    time_prep: Optional[float] = None
    time_total: Optional[float] = None
    portions: Optional[float] = None
    recipe_url: Optional[str] = None

    ingredients: Optional[list[IngredientCreate]] = None
    nutritions: Optional[list[NutritionCreate]] = None

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