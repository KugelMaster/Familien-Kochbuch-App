from datetime import datetime, timedelta

from fastapi import APIRouter, HTTPException
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jose import JWTError, jwt
from passlib.context import CryptContext
from pydantic import BaseModel
from sqlalchemy.orm import Session
from starlette import status

from database import SessionLocal, db_dependency
from models import User

router = APIRouter(prefix="/auth", tags=["Authentication"])

bcyrpt_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_bearer = OAuth2PasswordBearer(tokenUrl="auth/token")


class CreateUserRequest(BaseModel):
    username: str
    password: str
    email: str


class Token(BaseModel):
    access_token: str
    token_type: str


@router.post("", status_code=status.HTTP_201_CREATED)
def create_user(user: CreateUserRequest, db: db_dependency):
    db_user = User(
        name=user.username,
        password_hash=bcyrpt_context.hash(user.password),
        email=user.email,
    )

    db.add(db_user)
    db.commit()
