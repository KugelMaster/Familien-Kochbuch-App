from sqlalchemy import Column, Integer, Float, String, Text, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
from database import Base

class Recipe(Base):
    __tablename__ = "recipes"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    image = Column(String, nullable=True) # Main Image URL from Backend API FIXME: Vllt. mit RecipeImage ID verknüpfen?
    description = Column(Text, nullable=True)
    time_prep = Column(Float, nullable=True) # type: ignore
    time_total = Column(Float, nullable=True) # type: ignore
    portions = Column(Float, default=1.0) # type: ignore
    recipe_url = Column(String, nullable=True)

    ingredients = relationship("Ingredient", cascade="all, delete-orphan")
    nutritions = relationship("Nutrition", cascade="all, delete-orphan")
    usernotes = relationship("UserNote", cascade="all, delete-orphan")
    ratings = relationship("Rating", cascade="all, delete-orphan")
    tags = relationship("Tag", secondary="recipe_tags", backref="recipes", cascade="all, delete")

    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

class Ingredient(Base):
    __tablename__ = "ingredients"

    id = Column(Integer, primary_key=True, index=True)
    recipe_id = Column(Integer, ForeignKey("recipes.id"))
    name = Column(String, nullable=False)
    amount = Column(String, nullable=True)
    unit = Column(String, nullable=True)

class Nutrition(Base):
    __tablename__ = "nutritions"

    id = Column(Integer, primary_key=True, index=True)
    recipe_id = Column(Integer, ForeignKey("recipes.id"))
    name = Column(String, nullable=False)
    amount = Column(String, nullable=True)
    unit = Column(String, nullable=True)

class UserNote(Base):
    __tablename__ = "usernotes"

    id = Column(Integer, primary_key=True, index=True)
    recipe_id = Column(Integer, ForeignKey("recipes.id"))
    user_id = Column(Integer, ForeignKey("users.id"))
    text = Column(Text, nullable=False)

    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

class Rating(Base):
    __tablename__ = "ratings"

    id = Column(Integer, primary_key=True, index=True)
    recipe_id = Column(Integer, ForeignKey("recipes.id"))
    user_id = Column(Integer, ForeignKey("users.id"))
    stars = Column(Float, nullable=False) # type: ignore
    comment = Column(Text, nullable=True)

    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))


class Tag(Base):
    __tablename__ = "tags"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, nullable=False)

class RecipeTag(Base):
    __tablename__ = "recipe_tags"

    recipe_id = Column(Integer, ForeignKey("recipes.id"), primary_key=True, index=True)
    tag_id = Column(Integer, ForeignKey("tags.id"), primary_key=True, index=True)


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    # TODO

class RecipeImage(Base):
    __tablename__ = "recipe_images"

    recipe_id = Column(Integer, ForeignKey("recipes.id"), primary_key=True, index=True)
    filename = Column(String, nullable=False)
    file_path = Column(String, nullable=False)
