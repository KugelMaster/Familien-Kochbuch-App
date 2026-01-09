from typing import Annotated, Any

from fastapi import Depends
from sqlalchemy.orm import Session

from database import get_db
from utils.authentication import get_current_user

DBDependency = Annotated[Session, Depends(get_db)]
UserDependency = Annotated[dict[str, Any], Depends(get_current_user)]
# IDK if this is actually worth it
# OptionalUserDep = Annotated[Optional[dict[str, Any]], Depends(get_optional_user)]
