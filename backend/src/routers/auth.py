from typing import Annotated

from fastapi import APIRouter, Depends
from fastapi.security import OAuth2PasswordRequestForm as OAuth2Form
from starlette import status

from dependencies import DBDependency
from models import User
from schemas import Token, UserCreate
from utils.authentication import authenticate_user, create_access_token, hash_password
from utils.http_exceptions import BadRequest

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/signup", status_code=status.HTTP_201_CREATED)
def create_user(user: UserCreate, db: DBDependency):
    if db.query(User).where(User.name == user.username).first():
        raise BadRequest("Username already exists")

    db_user = User(
        name=user.username,
        password_hash=hash_password(user.password),
        email=user.email,
        is_admin=user.is_admin,
    )

    db.add(db_user)
    db.commit()


@router.post("/token", response_model=Token)
def login_for_access_token(data: Annotated[OAuth2Form, Depends()], db: DBDependency):
    user = authenticate_user(data.username, data.password, db)
    token = create_access_token(user.name, user.id, user.is_admin)

    return {"access_token": token, "token_type": "bearer"}
