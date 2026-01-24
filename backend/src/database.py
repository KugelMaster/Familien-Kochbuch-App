from datetime import datetime, timezone

from sqlalchemy import create_engine, event
from sqlalchemy.orm import Session, sessionmaker

from config import config
from models import Base

engine = create_engine(config.DATABASE_URL)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)


def init_db():
    """
    This function initializes the database with every table declared in models.py.
    It also binds the engine to there Base Model.
    """
    Base.metadata.create_all(bind=engine)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@event.listens_for(Session, "before_flush")
def _update_timestamp_on_relationship_change(session: Session, flush_context, instances):  # type: ignore
    """
    Automatically updates the 'updated_at' timestamp of parent records
    when related child records are added, modified, or deleted.
    """
    for instance in session.new.union(session.dirty).union(session.deleted):
        if session.is_modified(instance, include_collections=True):
            if hasattr(instance, "updated_at"):
                instance.updated_at = datetime.now(timezone.utc)
