from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class TagCreate(BaseModel):
    name: str

class IngredientCreate(BaseModel):
    name: str
    amount: Optional[float] = None
    unit: Optional[str] = None

class NutritionCreate(BaseModel):
    name: str
    amount: Optional[float] = None
    unit: Optional[str] = None

class RecipeNoteCreate(BaseModel):
    recipe_id: int
    user_id: int
    content: str

class RatingCreate(BaseModel):
    recipe_id: int
    user_id: int
    stars: float # Zwischen 0 und 5 mit 0,5 Schritten
    comment: Optional[str] = None

class RecipeCreate(BaseModel):
    title: str
    tags: Optional[list[int]] = None
    image_id: Optional[int] = None
    description: Optional[str] = None
    time_prep: Optional[int] = None
    time_total: Optional[int] = None
    portions: Optional[float] = None
    recipe_uri: Optional[str] = None

    ingredients: Optional[list[IngredientCreate]] = None
    nutritions: Optional[list[NutritionCreate]] = None # TODO: Vllt. später automatisch aus Zutaten berechnen?

class TagOut(BaseModel):
    id: int
    name: str

class RecipeNoteOut(BaseModel):
    id: int
    recipe_id: int
    user_id: Optional[int]
    content: str

    created_at: Optional[datetime]
    updated_at: Optional[datetime]

class RatingOut(BaseModel):
    id: int
    user_id: int
    stars: float # Zwischen 0 und 5 mit 0,5 Schritten
    comment: Optional[str] = None

    created_at: Optional[datetime]
    updated_at: Optional[datetime]

class RecipeOutSimple(BaseModel):
    id: int
    title: str

    class Config:
        from_attributes = True

class RecipeResponse(BaseModel):
    id: int
    title: str
    tags: Optional[list[TagOut]] = None
    image_id: Optional[int] = None
    description: Optional[str] = None
    time_prep: Optional[int] = None
    time_total: Optional[int] = None
    portions: Optional[float] = None
    recipe_uri: Optional[str] = None

    ingredients: Optional[list[IngredientCreate]] = None
    nutritions: Optional[list[NutritionCreate]] = None # Vllt. später automatisch aus Zutaten berechnen?
    recipe_notes: Optional[list[RecipeNoteOut]] = None
    ratings: Optional[list[RatingOut]] = None

    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class ImageUploadResponse(BaseModel):
    id: int
    filename: str

    class Config:
        from_attributes = True 


class RecipeUpdate(BaseModel):
    title: Optional[str] = None
    tags: Optional[list[int]] = None
    image_id: Optional[int] = None
    description: Optional[str] = None
    time_prep: Optional[int] = None
    time_total: Optional[int] = None
    portions: Optional[float] = None
    recipe_uri: Optional[str] = None

    ingredients: Optional[list[IngredientCreate]] = None # FIXME: Später mit IDs arbeiten
    nutritions: Optional[list[NutritionCreate]] = None # FIXME: Später mit IDs arbeiten

    class Config:
        from_attributes = True

class RecipeNoteUpdate(BaseModel):
    content: str



class Message(BaseModel):
    detail: str
