from datetime import datetime

from sqlalchemy import ForeignKey, func
from sqlalchemy.orm import Mapped, mapped_column

from .base import Base


class CookingHistory(Base):
    __tablename__ = "cooking_history"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    recipe_id: Mapped[int] = mapped_column(ForeignKey("recipes.id"))
    cooked_by: Mapped[int | None] = mapped_column(ForeignKey("users.id"))
    cooked_at: Mapped[datetime | None] = mapped_column()
    # Please increase the number by one depending on the last one!
    times_cooked: Mapped[int] = mapped_column()


class UserHistory(Base):
    __tablename__ = "user_history"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    last_cooked: Mapped[int | None] = mapped_column(ForeignKey("recipes.id"))

    updated_at: Mapped[datetime] = mapped_column(server_default=func.now())
