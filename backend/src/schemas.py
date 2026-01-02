from pydantic import BaseModel, Field, field_validator
from typing import Any, Optional
from datetime import datetime


###############################################[Tags]###############################################
class TagCreate(BaseModel):
    name: str

class TagOut(BaseModel):
    id: int
    name: str

###########################################[Ingredients]############################################
class IngredientCreate(BaseModel):
    name: str
    amount: Optional[float] = None
    unit: Optional[str] = None

############################################[Nutritions]############################################
class NutritionCreate(BaseModel):
    name: str
    amount: Optional[float] = None
    unit: Optional[str] = None

###########################################[RecipeNotes]############################################
class RecipeNoteCreate(BaseModel):
    recipe_id: int
    user_id: int
    content: str

class RecipeNoteOut(BaseModel):
    id: int
    recipe_id: int
    user_id: Optional[int]
    content: str

    created_at: datetime
    updated_at: datetime

class RecipeNoteUpdate(BaseModel):
    content: str

#############################################[Ratings]##############################################
class RatingCreate(BaseModel):
    recipe_id: int
    user_id: int
    stars: float = Field(ge=0, le=5, description="Rating in Stars from 0 to 5 in 0,5 increments")
    comment: Optional[str] = None

    @field_validator("stars")
    @classmethod
    def validate_stars(cls, v: Any):
        if not isinstance(v, float): raise TypeError("Stars must be a float")

        if v * 2 % 1 != 0:
            raise ValueError("Stars must be in 0.5 increments")
        return v

class RatingOut(BaseModel):
    id: int
    recipe_id: int
    user_id: int
    stars: float = Field(ge=0, le=5, description="Rating in Stars from 0 to 5 in 0,5 increments")
    comment: Optional[str] = None

    created_at: datetime
    updated_at: datetime

class RatingAverageOut(BaseModel):
    average_stars: float = Field(ge=0, le=5, description="Average Rating in Stars from 0 to 5")
    total_ratings: int

class RatingUpdate(BaseModel):
    stars: float = Field(ge=0, le=5, description="Rating in Stars from 0 to 5 in 0,5 increments")
    comment: Optional[str] = None

    @field_validator("stars")
    @classmethod
    def validate_stars(cls, v: Any):
        if not isinstance(v, float): raise TypeError("Stars must be a float")

        if v * 2 % 1 != 0:
            raise ValueError("Stars must be in 0.5 increments")
        return v

#############################################[Recipes]##############################################
class RecipeCreate(BaseModel):
    title: str
    tags: Optional[list[int]] = None
    image_id: Optional[int] = None
    description: Optional[str] = None
    time_prep: Optional[int] = Field(None, ge=0)
    time_total: Optional[int] = Field(None, ge=0)
    portions: Optional[float] = Field(None, gt=0)
    recipe_uri: Optional[str] = None

    ingredients: Optional[list[IngredientCreate]] = None
    nutritions: Optional[list[NutritionCreate]] = None # TODO: Vllt. später automatisch aus Zutaten berechnen?

class RecipeResponse(BaseModel):
    id: int
    title: str
    tags: list[TagOut]
    image_id: Optional[int] = None
    description: Optional[str] = None
    time_prep: Optional[int] = Field(None, ge=0)
    time_total: Optional[int] = Field(None, ge=0)
    portions: Optional[float] = Field(None, gt=0)
    recipe_uri: Optional[str] = None

    ingredients: list[IngredientCreate]
    nutritions: list[NutritionCreate]
    recipe_notes: list[RecipeNoteOut]
    ratings: list[RatingOut]

    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class RecipeUpdate(BaseModel):
    title: Optional[str] = None
    tags: Optional[list[int]] = None
    image_id: Optional[int] = None
    description: Optional[str] = None
    time_prep: Optional[int] = Field(None, ge=0)
    time_total: Optional[int] = Field(None, ge=0)
    portions: Optional[float] = Field(None, gt=0)
    recipe_uri: Optional[str] = None

    ingredients: Optional[list[IngredientCreate]] = None # FIXME: Später mit IDs arbeiten
    nutritions: Optional[list[NutritionCreate]] = None # FIXME: Später mit IDs arbeiten

    class Config:
        from_attributes = True


class RecipeOutSimple(BaseModel):
    id: int
    title: str
    image_id: Optional[int] = None
    time_total: Optional[int]
    rating: float = Field(ge=0, le=5)
    total_ratings: int

    class Config:
        from_attributes = True

##############################################[Images]##############################################
class ImageUploadResponse(BaseModel):
    id: int
    filename: str

    class Config:
        from_attributes = True 

##############################################[Other]###############################################
class Message(BaseModel):
    detail: str
