from sqlalchemy import Column, Integer, Float, String, Text, ForeignKey, DateTime, UniqueConstraint, func
from sqlalchemy.orm import relationship
from database import Base

class Recipe(Base):
    __tablename__ = "recipes"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    image_id = Column(Integer, ForeignKey("images.id", ondelete="SET NULL"), nullable=True)
    description = Column(Text, nullable=True)
    time_prep = Column(Integer, nullable=True) # type: ignore
    time_total = Column(Integer, nullable=True) # type: ignore
    portions = Column(Float, nullable=True) # type: ignore
    recipe_uri = Column(String, nullable=True)

    ingredients = relationship("Ingredient", cascade="all, delete-orphan")
    nutritions = relationship("Nutrition", cascade="all, delete-orphan")
    recipe_notes = relationship("RecipeNote", back_populates="recipe", cascade="all, delete-orphan")
    ratings = relationship("Rating", cascade="all, delete-orphan")
    tags = relationship("Tag", secondary="recipe_tags", backref="recipes")

    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now())


class Ingredient(Base):
    __tablename__ = "ingredients"

    id = Column(Integer, primary_key=True, index=True)
    recipe_id = Column(Integer, ForeignKey("recipes.id"))
    name = Column(String, nullable=False)
    amount = Column(Float, nullable=True) # type: ignore
    unit = Column(String, nullable=True)


class Nutrition(Base):
    __tablename__ = "nutritions"

    id = Column(Integer, primary_key=True, index=True)
    recipe_id = Column(Integer, ForeignKey("recipes.id"))
    name = Column(String, nullable=False)
    amount = Column(Float, nullable=True) # type: ignore
    unit = Column(String, nullable=True)


class RecipeNote(Base):
    __tablename__ = "recipe_notes"

    id = Column(Integer, primary_key=True, index=True)
    recipe_id = Column(Integer, ForeignKey("recipes.id", ondelete="CASCADE"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    content = Column(Text, nullable=False)

    recipe = relationship("Recipe", back_populates="recipe_notes")
    user = relationship("User", back_populates="recipe_notes")

    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now())

    __table_args__ = (
        UniqueConstraint('recipe_id', 'user_id', name='uq_user_recipe_note'),
    )


class Rating(Base):
    __tablename__ = "ratings"

    id = Column(Integer, primary_key=True, index=True)
    recipe_id = Column(Integer, ForeignKey("recipes.id"))
    user_id = Column(Integer, ForeignKey("users.id"))
    stars = Column(Float, nullable=False) # type: ignore
    comment = Column(Text, nullable=True)

    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now())


class Tag(Base):
    __tablename__ = "tags"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, nullable=False)

class RecipeTag(Base):
    __tablename__ = "recipe_tags"

    recipe_id = Column(Integer, ForeignKey("recipes.id", ondelete="CASCADE"), primary_key=True, index=True)
    tag_id = Column(Integer, ForeignKey("tags.id", ondelete="CASCADE"), primary_key=True, index=True)


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    #TODO: 
    
    recipe_notes = relationship("RecipeNote", back_populates="user")

    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now())
"""
class User(BaseModel):
    id: UUID
    name: str
    #email: str
    avatar_url: str
    created_at: str
    updated_at: str
"""

class Image(Base):
    __tablename__ = "images"

    id = Column(Integer, primary_key=True, index=True)
    filename = Column(String, nullable=False)
    file_path = Column(String, nullable=False)
    uploaded_by = Column(Integer, ForeignKey("users.id"), nullable=True)

    created_at = Column(DateTime, server_default=func.now())
