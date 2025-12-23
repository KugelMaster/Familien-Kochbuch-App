from fastapi import FastAPI
from fastapi.responses import HTMLResponse

from routers import recipe_notes, recipes, ratings, images, tags
from database import Base, engine

from tests.test_user import main as test_user_main


tags_metadata = [
    {
        "name": "Recipes",
        "description": "Operations with recipes.",
    },
    {
        "name": "RecipeNotes",
        "description": "Operations with user notes.",
    },
    {
        "name": "Ratings",
        "description": "Operations with ratings.",
    },
    {
        "name": "Images",
        "description": "Operations with images.",
    },
    {
        "name": "Tags",
        "description": "Operations with tags.",
    }
]

app = FastAPI(
    title="Family Cookbook API",
    description="Backend API for the Family Cookbook App",
    version="0.1.1",
    openapi_tags=tags_metadata
)

Base.metadata.create_all(bind=engine)

app.include_router(recipes.router)
app.include_router(recipe_notes.router)
app.include_router(ratings.router)
app.include_router(images.router)
app.include_router(tags.router)


@app.get("/", response_class=HTMLResponse)
async def root():
    return """
        <div style="height: 100vh; display: flex; align-items: center; justify-content: center">
            <a href="/docs" style="font-size: 100px">Hier ist der Link zu den Docs</a>
        </div>
    """

test_user_main()
