import logging
import os
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse, JSONResponse
from sqlalchemy.exc import OperationalError

import routers
from database import init_db
from utils.http_exceptions import ServiceException

_logger = logging.getLogger("uvicorn.error")

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
    },
    {
        "name": "Search",
        "description": "Search for recipes.",
    },
    {
        "name": "Authentication",
        "description": "Authentication critical operations.",
    },
    {
        "name": "Users",
        "description": "Operations with users.",
    },
    {
        "name": "Analytics",
        "description": "Collect and fetch user data to improve user experience.",
    },
    {
        "name": "Planer",
        "description": "Operations related to meal planning and shopping lists.",
    },
    {"name": "Test", "description": "Routes for testing purposes."},
]


@asynccontextmanager
async def lifespan(app: FastAPI):
    try:
        init_db()
    except OperationalError as e:
        _logger.critical("[red]Failed to connect to the database:\n%s[/red]", e)
        os._exit(1)
    yield


app = FastAPI(
    title="Family Cookbook API",
    description="Backend API for the Family Cookbook App",
    version="0.1.3",
    openapi_tags=tags_metadata,
    lifespan=lifespan,
)

for router in [getattr(routers, name).router for name in routers.__all__]:
    app.include_router(router)


@app.exception_handler(ServiceException)
def service_exception_handler(request: Request, exc: ServiceException):
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "status": exc.status,
            "code": exc.code,
            "detail": exc.detail,
        },
    )


@app.exception_handler(OperationalError)
def db_exception_handler(request: Request, exc: OperationalError):
    _logger.error("[red]Database operational error:\n%s[/red]", exc)

    return JSONResponse(
        status_code=503,
        content={
            "status": "ERROR",
            "code": "DB_UNAVAILABLE",
            "detail": "The database is currently unavailable. Please try again later.",
        },
    )


@app.exception_handler(Exception)
def generic_exception_handler(request: Request, exc: Exception):
    _logger.error("[red]An unexpected error occurred: %s[/red]", exc)

    return JSONResponse(
        status_code=500,
        content={
            "status": "ERROR",
            "code": "INTERNAL_SERVER_ERROR",
            "detail": "An unexpected error occurred. Please try again later.",
        },
    )


@app.get("/", response_class=HTMLResponse)
async def root():
    return """
        <div style="height: 100vh; display: flex; align-items: center; justify-content: center">
            <a href="/docs" style="font-size: 100px">Hier ist der Link zu den Docs</a>
        </div>
    """
