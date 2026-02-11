from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import ForeignKey, Text, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .base import Base

if TYPE_CHECKING:
    from .user import Rating, RecipeNote


class Recipe(Base):
    __tablename__ = "recipes"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    title: Mapped[str] = mapped_column(Text)
    image_id: Mapped[int | None] = mapped_column(
        ForeignKey("images.id", ondelete="SET NULL")
    )
    description: Mapped[str | None] = mapped_column()
    time_prep: Mapped[int | None] = mapped_column()
    time_total: Mapped[int | None] = mapped_column()
    portions: Mapped[float | None] = mapped_column()
    recipe_uri: Mapped[str | None] = mapped_column()

    ingredients: Mapped[list["Ingredient"]] = relationship(cascade="all, delete-orphan")
    nutritions: Mapped[list["Nutrition"]] = relationship(cascade="all, delete-orphan")
    recipe_notes: Mapped[list["RecipeNote"]] = relationship(
        back_populates="recipe", cascade="all, delete-orphan"
    )
    ratings: Mapped[list["Rating"]] = relationship(cascade="all, delete-orphan")
    tags: Mapped[list["Tag"]] = relationship(secondary="recipe_tags", backref="recipes")

    created_at: Mapped[datetime] = mapped_column(server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(server_default=func.now())


class Ingredient(Base):
    __tablename__ = "ingredients"

    id: Mapped[int] = mapped_column(primary_key=True)
    recipe_id: Mapped[int] = mapped_column(ForeignKey("recipes.id"))
    name: Mapped[str] = mapped_column()
    amount: Mapped[float | None] = mapped_column()
    unit: Mapped[str | None] = mapped_column()


class Nutrition(Base):
    __tablename__ = "nutritions"

    id: Mapped[int] = mapped_column(primary_key=True)
    recipe_id: Mapped[int] = mapped_column(ForeignKey("recipes.id"))
    name: Mapped[str] = mapped_column()
    amount: Mapped[float | None] = mapped_column()
    unit: Mapped[str | None] = mapped_column()


class Tag(Base):
    __tablename__ = "tags"

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(unique=True)
