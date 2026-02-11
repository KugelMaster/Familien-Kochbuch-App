from datetime import datetime

from sqlalchemy import CheckConstraint, ForeignKey, Numeric, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from schemas import Role

from .base import Base

# from typing import TYPE_CHECKING


# if TYPE_CHECKING:
# from .recipe import Recipe


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(80), unique=True)
    password_hash: Mapped[str] = mapped_column(String(255))  # Vllt. reicht auch 100?
    email: Mapped[str | None] = mapped_column(String(255))
    avatar_id: Mapped[int | None] = mapped_column(
        ForeignKey("images.id", ondelete="SET NULL")
    )
    role: Mapped[Role] = mapped_column(default=Role.user)

    recipe_notes: Mapped[list["RecipeNote"]] = relationship()
    ratings: Mapped[list["Rating"]] = relationship()

    created_at: Mapped[datetime] = mapped_column(server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(server_default=func.now())


class RecipeNote(Base):
    __tablename__ = "recipe_notes"

    id: Mapped[int] = mapped_column(primary_key=True)
    recipe_id: Mapped[int] = mapped_column(ForeignKey("recipes.id", ondelete="CASCADE"))
    user_id: Mapped[int | None] = mapped_column(
        ForeignKey("users.id", ondelete="SET NULL")
    )
    content: Mapped[str] = mapped_column(Text)

    created_at: Mapped[datetime] = mapped_column(server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(server_default=func.now())


class Rating(Base):
    __tablename__ = "ratings"

    id: Mapped[int] = mapped_column(primary_key=True)
    recipe_id: Mapped[int] = mapped_column(ForeignKey("recipes.id"))
    user_id: Mapped[int | None] = mapped_column(
        ForeignKey("users.id", ondelete="SET NULL")
    )
    stars: Mapped[float] = mapped_column(
        Numeric(precision=2, scale=1, asdecimal=False),
        CheckConstraint("stars >= 0 AND stars <= 5.0"),
    )
    comment: Mapped[str | None] = mapped_column(Text)

    created_at: Mapped[datetime] = mapped_column(server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(server_default=func.now())
