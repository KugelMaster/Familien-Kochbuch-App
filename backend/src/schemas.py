from datetime import datetime
from enum import Enum
from typing import Any, Optional

from pydantic import BaseModel, ConfigDict, EmailStr, Field, field_validator


###############################################[Tags]###############################################
class TagCreate(BaseModel):
    name: str

    model_config = ConfigDict(extra="forbid")


class TagOut(BaseModel):
    id: int
    name: str


###########################################[Ingredients]############################################
class IngredientCreate(BaseModel):
    name: str
    amount: Optional[float] = None
    unit: Optional[str] = None

    model_config = ConfigDict(extra="forbid")


############################################[Nutritions]############################################
class NutritionCreate(BaseModel):
    name: str
    amount: Optional[float] = None
    unit: Optional[str] = None

    model_config = ConfigDict(extra="forbid")


###########################################[RecipeNotes]############################################
class RecipeNoteCreate(BaseModel):
    recipe_id: int
    content: str

    model_config = ConfigDict(extra="forbid")


class RecipeNoteOut(BaseModel):
    id: int
    recipe_id: int
    user_id: Optional[int]
    content: str

    created_at: datetime
    updated_at: datetime


class RecipeNoteUpdate(BaseModel):
    content: str

    model_config = ConfigDict(extra="forbid")


#############################################[Ratings]##############################################
class RatingCreate(BaseModel):
    recipe_id: int
    stars: float = Field(
        ge=0, le=5, description="Rating in Stars from 0 to 5 in 0,5 increments"
    )
    comment: Optional[str] = None

    @field_validator("stars")
    @classmethod
    def validate_stars(cls, v: Any):
        if not isinstance(v, float):
            raise TypeError("Stars must be a float")

        if v * 2 % 1 != 0:
            raise ValueError("Stars must be in 0.5 increments")
        return v

    model_config = ConfigDict(extra="forbid")


class RatingOut(BaseModel):
    id: int
    recipe_id: int
    user_id: int
    stars: float = Field(
        ge=0, le=5, description="Rating in Stars from 0 to 5 in 0,5 increments"
    )
    comment: Optional[str] = None

    created_at: datetime
    updated_at: datetime


class RatingAverageOut(BaseModel):
    average_stars: float = Field(
        ge=0, le=5, description="Average Rating in Stars from 0 to 5"
    )
    total_ratings: int


class RatingUpdate(BaseModel):
    stars: float = Field(
        ge=0, le=5, description="Rating in Stars from 0 to 5 in 0,5 increments"
    )
    comment: Optional[str] = None

    @field_validator("stars")
    @classmethod
    def validate_stars(cls, v: Any):
        if not isinstance(v, float):
            raise TypeError("Stars must be a float")

        if v * 2 % 1 != 0:
            raise ValueError("Stars must be in 0.5 increments")
        return v

    model_config = ConfigDict(extra="forbid")


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
    # TODO: Vllt. später automatisch aus Zutaten berechnen?
    nutritions: Optional[list[NutritionCreate]] = None

    model_config = ConfigDict(extra="forbid")


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

    model_config = ConfigDict(from_attributes=True)


class RecipeUpdate(BaseModel):
    title: Optional[str] = None
    tags: Optional[list[int]] = None
    image_id: Optional[int] = None
    description: Optional[str] = None
    time_prep: Optional[int] = Field(None, ge=0)
    time_total: Optional[int] = Field(None, ge=0)
    portions: Optional[float] = Field(None, gt=0)
    recipe_uri: Optional[str] = None

    ingredients: Optional[list[IngredientCreate]] = None
    nutritions: Optional[list[NutritionCreate]] = None

    model_config = ConfigDict(extra="forbid", from_attributes=True)


class RecipeOutSimple(BaseModel):
    id: int
    title: str
    image_id: Optional[int] = None
    time_total: Optional[int]
    rating: float = Field(ge=0, le=5)
    total_ratings: int

    model_config = ConfigDict(from_attributes=True)


##############################################[Images]##############################################
class ImageTag(str, Enum):
    avatar = "avatar"
    recipe = "recipe"


class ImageUploadResponse(BaseModel):
    id: int
    filename: str = Field(..., max_length=255, description="Filename without path")
    tag: ImageTag
    uploaded_by: Optional[int] = None

    model_config = ConfigDict(from_attributes=True)


###########################################[Permissions]############################################
class Role(str, Enum):
    user = "user"
    admin = "admin"


##############################################[Users]###############################################
class UserCreate(BaseModel):
    username: str = Field(..., max_length=80, description="Complete name of the user")
    password: str
    email: Optional[EmailStr] = Field(
        None, max_length=255, description="Email address of the user"
    )
    role: Role = Role.user  # FIXME: Später für Sicherheit natürlich entfernen ;-)

    model_config = ConfigDict(extra="forbid")


class UserUpdate(BaseModel):
    username: Optional[str] = Field(
        None, max_length=80, description="Complete name of the user"
    )
    email: Optional[EmailStr] = Field(
        None, max_length=255, description="Email address of the user"
    )
    avatar_id: Optional[int] = None
    role: Optional[Role] = None  # FIXME: Später für Sicherheit natürlich entfernen ;-)

    model_config = ConfigDict(extra="forbid")


class UserPasswordUpdate(BaseModel):
    current_password: str
    new_password: str

    model_config = ConfigDict(extra="forbid")


class UserDetailedOut(BaseModel):
    id: int
    name: str
    email: Optional[EmailStr] = None
    avatar_id: Optional[int] = None
    role: Role

    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class UserSimpleOut(BaseModel):
    id: int
    name: str
    avatar_id: Optional[int] = None

    model_config = ConfigDict(from_attributes=True)


##########################################[Authentication]##########################################
class Token(BaseModel):
    access_token: str
    token_type: str


class TokenData(BaseModel):
    user_id: int
    role: Role

    @property
    def is_admin(self) -> bool:
        return self.role == Role.admin


##############################################[Other]###############################################
class Message(BaseModel):
    detail: str
