from database import SessionLocal
from models import User
from schemas import Role
from utils.authentication import hash_password


def main() -> None:
    db = SessionLocal()

    if db.query(User).filter(User.id == 1).first() is not None:
        return

    db_user = User(
        id=1,
        name="dev",
        password_hash=hash_password("dev123"),
        email="dev@dev.com",
        role=Role.admin,
    )

    db.add(db_user)
    db.commit()

    db.close()
