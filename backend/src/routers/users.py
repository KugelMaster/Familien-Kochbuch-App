from fastapi import APIRouter
from starlette import status

from dependencies import DBDependency
from models import User
from schemas import ErrorCode, UserCreate, UserSimpleOut
from utils.authentication import hash_password
from utils.http_exceptions import BadRequest, NotFound

router = APIRouter(prefix="/users", tags=["Users"])


@router.post("/signup", status_code=status.HTTP_201_CREATED)
def create_user(user: UserCreate, db: DBDependency):
    if db.query(User).where(User.name == user.username).first():
        raise BadRequest("Username already exists", code=ErrorCode.USERNAME_EXISTS)

    db_user = User(
        name=user.username,
        password_hash=hash_password(user.password),
        email=user.email,
        role=user.role,
    )

    db.add(db_user)
    db.commit()


@router.get("/{user_id}", response_model=UserSimpleOut)
def get_user(user_id: int, db: DBDependency):
    db_user = db.query(User).filter(User.id == user_id).first()

    if not db_user:
        raise NotFound("User not found")

    return db_user
