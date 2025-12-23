from database import SessionLocal
from models import User


def main() -> None:
    db = SessionLocal()

    if db.query(User).filter(User.id == 1).first() is not None:
        return
    
    db_user = User(
        id=1,
        name="dev",
    )

    db.add(db_user)
    db.commit()
