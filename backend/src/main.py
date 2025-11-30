from fastapi import FastAPI
#from fastapi.middleware.cors import CORSMiddleware
from routers import recipes
from database import Base, engine


app = FastAPI(
    title="Cooking App API",
    description="Backend API for the Cooking App",
    version="0.1.0"
)

# Das sind die Adressen, die auf die API zugreifen DÜRFEN.
# Wenn das Frontend Port 8080 nutzt, muss dieser auch erlaubt sein.
#origins = [
#    "http://localhost",
#    "http://127.0.0.1"
#]
#
#app.add_middleware(
#    CORSMiddleware,
#    allow_origins=origins,
#    allow_credentials=True,
#    allow_methods=["*"],
#    allow_headers=["*"],
#)

Base.metadata.create_all(bind=engine)

app.include_router(recipes.router)


@app.get("/", response_model=str)
async def root() -> str:
    return '<a href="/docs">Hier ist der Link zu den Docs</p>'
