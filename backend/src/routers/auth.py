from typing import Annotated

from fastapi import APIRouter, Depends
from fastapi.security import OAuth2PasswordRequestForm as OAuth2Form
from starlette import status

from dependencies import DBDependency, UserDependency
from models import User
from schemas import Message, Token, UserDetailedOut, UserPasswordUpdate, UserUpdate
from utils.authentication import authenticate_user, create_access_token, hash_password
from utils.http_exceptions import BadRequest

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.get("/me", response_model=UserDetailedOut)
def get_user_info(user: UserDependency, db: DBDependency):
    db_user = db.query(User).filter(User.id == user.user_id).first()

    return db_user


@router.patch("/me", response_model=UserDetailedOut)
def update_user_profile(
    updated_user: UserUpdate,
    user: UserDependency,
    db: DBDependency,
):
    db_user = db.query(User).filter(User.id == user.user_id).first()

    if not db_user:
        raise BadRequest("User not found")

    patch = updated_user.model_dump(exclude_unset=True)
    username = patch.pop("username", None)

    if username and username != db_user.name:
        if db.query(User).where(User.name == username).first():
            raise BadRequest("Username already exists")
        db_user.name = username

    for key, value in patch.items():
        setattr(db_user, key, value)

    db.commit()
    db.refresh(db_user)

    return db_user


@router.patch("/me/password", status_code=status.HTTP_204_NO_CONTENT)
def change_user_password(
    passwords: UserPasswordUpdate,
    user: UserDependency,
    db: DBDependency,
):
    db_user = db.query(User).filter(User.id == user.user_id).first()

    if not db_user:
        raise BadRequest("User not found")

    if not passwords.new_password:
        raise BadRequest("New password must be provided")

    authenticate_user(db_user.name, passwords.current_password, db)

    db_user.password_hash = hash_password(passwords.new_password)

    db.commit()


@router.post("/token", response_model=Token)
def login_for_access_token(data: Annotated[OAuth2Form, Depends()], db: DBDependency):
    user = authenticate_user(data.username, data.password, db)
    token = create_access_token(user.id, user.role)

    return {"access_token": token, "token_type": "bearer"}


@router.delete("/me", response_model=Message)
def delete_user_account(
    user: UserDependency,
    db: DBDependency,
):
    db_user = db.query(User).filter(User.id == user.user_id).first()

    if not db_user:
        raise BadRequest("User not found")

    db.delete(db_user)
    db.commit()

    return Message(detail="User account deleted successfully")
