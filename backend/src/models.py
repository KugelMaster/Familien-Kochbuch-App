from datetime import datetime

from sqlalchemy import CheckConstraint, ForeignKey, Numeric, String, Text, func
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship

from schemas import ImageTag, Role


class Base(DeclarativeBase):
    pass


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


class RecipeNote(Base):
    __tablename__ = "recipe_notes"

    id: Mapped[int] = mapped_column(primary_key=True)
    recipe_id: Mapped[int] = mapped_column(ForeignKey("recipes.id", ondelete="CASCADE"))
    user_id: Mapped[int | None] = mapped_column(
        ForeignKey("users.id", ondelete="SET NULL")
    )
    content: Mapped[str] = mapped_column(Text)

    recipe: Mapped["Recipe"] = relationship(back_populates="recipe_notes")
    user: Mapped["User"] = relationship(back_populates="recipe_notes")

    created_at: Mapped[datetime] = mapped_column(server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(server_default=func.now())


class Rating(Base):
    __tablename__ = "ratings"

    id: Mapped[int] = mapped_column(primary_key=True)
    recipe_id: Mapped[int] = mapped_column(ForeignKey("recipes.id"))
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="SET NULL"))
    stars: Mapped[float] = mapped_column(
        Numeric(precision=2, scale=1, asdecimal=False),
        CheckConstraint("stars >= 0 AND stars <= 5.0"),
    )
    comment: Mapped[str | None] = mapped_column(Text)

    created_at: Mapped[datetime] = mapped_column(server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(server_default=func.now())


class Tag(Base):
    __tablename__ = "tags"

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(unique=True)


class RecipeTag(Base):
    __tablename__ = "recipe_tags"

    recipe_id: Mapped[int] = mapped_column(
        ForeignKey("recipes.id", ondelete="CASCADE"),
        primary_key=True,
    )
    tag_id: Mapped[int] = mapped_column(
        ForeignKey("tags.id", ondelete="CASCADE"), primary_key=True
    )


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

    recipe_notes: Mapped[list["RecipeNote"]] = relationship(back_populates="user")

    created_at: Mapped[datetime] = mapped_column(server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(server_default=func.now())


class Image(Base):
    __tablename__ = "images"

    id: Mapped[int] = mapped_column(primary_key=True)
    filename: Mapped[str] = mapped_column(String(255))
    file_path: Mapped[str] = mapped_column(String(1024))
    tag: Mapped[ImageTag] = mapped_column()
    uploaded_by: Mapped[int | None] = mapped_column(
        ForeignKey("users.id", ondelete="SET NUll")
    )

    created_at: Mapped[datetime] = mapped_column(server_default=func.now())
