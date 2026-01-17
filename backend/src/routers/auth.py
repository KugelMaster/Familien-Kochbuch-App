from typing import Annotated

from fastapi import APIRouter, Depends
from fastapi.security import OAuth2PasswordRequestForm as OAuth2Form
from starlette import status

from dependencies import DBDependency, UserDependency
from models import User
from schemas import Token, UserCreate, UserOut, UserUpdate
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
        role=user.role,
    )

    db.add(db_user)
    db.commit()


@router.post("/me", response_model=UserOut)
def get_user_info(user: UserDependency, db: DBDependency):
    db_user = db.query(User).filter(User.id == user.user_id).first()

    return db_user


@router.patch("/me", response_model=UserOut)
def update_user_profile(
    updated_user: UserUpdate,
    user: UserDependency,
    db: DBDependency,
):
    db_user = db.query(User).filter(User.id == user.user_id).first()

    if not db_user:
        raise BadRequest("User not found")

    if updated_user.username and updated_user.username != db_user.name:
        if db.query(User).where(User.name == updated_user.username).first():
            raise BadRequest("Username already exists")
        db_user.name = updated_user.username

    if updated_user.password:
        db_user.password_hash = hash_password(updated_user.password)

    if updated_user.email:
        db_user.email = updated_user.email

    if updated_user.role:
        db_user.role = updated_user.role

    db.commit()
    db.refresh(db_user)

    return db_user


@router.post("/token", response_model=Token)
def login_for_access_token(data: Annotated[OAuth2Form, Depends()], db: DBDependency):
    user = authenticate_user(data.username, data.password, db)
    token = create_access_token(user.id, user.role)

    return {"access_token": token, "token_type": "bearer"}
