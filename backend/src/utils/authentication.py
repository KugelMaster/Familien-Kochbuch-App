from datetime import datetime, timezone
from typing import Annotated, Any

from argon2 import PasswordHasher
from argon2.exceptions import InvalidHashError, VerificationError, VerifyMismatchError
from fastapi import Depends
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from sqlalchemy.orm import Session

from config import config
from models import User
from schemas import UserTokenPayload
from utils.http_exceptions import BadRequest, Unauthorized

password_hasher = PasswordHasher()
oauth2_bearer = OAuth2PasswordBearer(tokenUrl="/auth/token")


def hash_password(password: str) -> str:
    return password_hasher.hash(password)


def authenticate_user(username: str, password: str, db: Session) -> User:
    user = db.query(User).filter(User.name == username).first()

    if not user:
        raise Unauthorized("Username or password is wrong")

    try:
        password_hasher.verify(user.password_hash, password)

        return user
    except VerifyMismatchError:
        raise Unauthorized("Username or password is wrong")
    except VerificationError:
        raise Unauthorized("Verification failed")
    except InvalidHashError:
        raise BadRequest("Hash could not be parsed")


def create_access_token(username: str, user_id: int, is_admin: bool) -> str:
    issued_at = datetime.now(timezone.utc)
    claims: dict[str, Any] = {
        "sub": username,
        "id": user_id,
        "is_admin": is_admin,
        "iat": issued_at,
    }
    return jwt.encode(claims, config.JWT_SECRET_KEY, algorithm=config.JWT_ALGORITHM)


def get_current_user(token: Annotated[str, Depends(oauth2_bearer)]) -> UserTokenPayload:
    try:
        payload = jwt.decode(
            token, config.JWT_SECRET_KEY, algorithms=[config.JWT_ALGORITHM]
        )
        username = payload.get("sub")
        user_id = payload.get("id")
        is_admin = payload.get("is_admin", False)
        if username is None or user_id is None:
            raise Unauthorized("User unauthorized")

        return UserTokenPayload(id=user_id, name=username, is_admin=is_admin)
    except JWTError:
        raise Unauthorized("Signature or claims invalid")


# def get_optional_user(token: Annotated[Optional[str], Depends(oauth2_bearer)] = None):
#     if token is None:
#         return

#     return get_current_user(token)
