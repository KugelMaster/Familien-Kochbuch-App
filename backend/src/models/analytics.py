from datetime import datetime

from sqlalchemy import DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column

from .base import Base


class RecipeCooked(Base):
    __tablename__ = "recipe_cooked"

    recipe_id: Mapped[int] = mapped_column(
        ForeignKey("recipes.id", ondelete="CASCADE"), primary_key=True
    )
    times_cooked: Mapped[int] = mapped_column()
    last_cooked: Mapped[datetime] = mapped_column(DateTime(timezone=True))


class CookingHistory(Base):
    __tablename__ = "cooking_history"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    recipe_id: Mapped[int] = mapped_column(ForeignKey("recipes.id", ondelete="CASCADE"))
    cooked_by: Mapped[int | None] = mapped_column(
        ForeignKey("users.id", ondelete="SET NULL")
    )
    cooked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
