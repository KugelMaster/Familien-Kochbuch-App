from fastapi import FastAPI
from fastapi.responses import HTMLResponse

from routers import recipes
from database import Base, engine


app = FastAPI(
    title="Cooking App API",
    description="Backend API for the Cooking App",
    version="0.1.0"
)

Base.metadata.create_all(bind=engine)

app.include_router(recipes.router)


@app.get("/", response_class=HTMLResponse)
async def root():
    return """
        <div style="height: 100vh; display: flex; align-items: center; justify-content: center">
            <a href="/docs" style="font-size: 100px">Hier ist der Link zu den Docs</a>
        </div>
    """
