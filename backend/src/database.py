from sqlalchemy import create_engine, event
from sqlalchemy.orm import sessionmaker, declarative_base, Session
from datetime import datetime, timezone

DATABASE_URL = "postgresql://cookbook:mysecretpassword@db:5432/cookbook"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
Base = declarative_base()

def get_db():
    """
    Provides a database session. Intended to be used as a FastAPI dependency.
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()



@event.listens_for(Session, "before_flush")
def _update_timestamp_on_relationship_change(session: Session, flush_context, instances): # type: ignore
    """
    Automatically updates the 'updated_at' timestamp of parent records
    when related child records are added, modified, or deleted.
    """
    for instance in session.new.union(session.dirty).union(session.deleted):
        if session.is_modified(instance, include_collections=True):
            if hasattr(instance, "updated_at"):
                instance.updated_at = datetime.now(timezone.utc)
