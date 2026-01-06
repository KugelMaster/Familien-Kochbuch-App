from typing import Annotated, Any

from fastapi import Depends
from sqlalchemy.orm import Session

from database import get_db
from utils.authentication import get_current_user

db_dependency = Annotated[Session, Depends(get_db)]
user_dependency = Annotated[dict[str, Any], Depends(get_current_user)]
