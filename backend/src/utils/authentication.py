from datetime import datetime, timezone
from typing import Annotated, Any

from argon2 import PasswordHasher
from argon2.exceptions import InvalidHashError, VerificationError, VerifyMismatchError
from fastapi import Depends
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from sqlalchemy.orm import Session

from config import JWT_ALGORITHM, JWT_SECRET_KEY
from models import User
from utils.http_exceptions import BadRequest, Unauthorized

password_hasher = PasswordHasher()
oauth2_bearer = OAuth2PasswordBearer(tokenUrl="/auth/token")

token_dependency = Annotated[str, Depends(oauth2_bearer)]


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


def create_access_token(username: str, user_id: int) -> str:
    issued_at = datetime.now(timezone.utc)
    claims: dict[str, Any] = {"sub": username, "id": user_id, "iat": issued_at}
    return jwt.encode(claims, JWT_SECRET_KEY, algorithm=JWT_ALGORITHM)


def get_current_user(token: token_dependency) -> dict[str, Any]:
    try:
        payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=[JWT_ALGORITHM])
        username = payload.get("sub")
        user_id = payload.get("id")
        if username is None or user_id is None:
            raise Unauthorized("User unauthorized")

        return {"username": username, "id": user_id}
    except JWTError:
        raise Unauthorized("Signature or claims invalid")
