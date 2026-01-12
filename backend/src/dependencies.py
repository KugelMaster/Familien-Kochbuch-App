from typing import Annotated, Optional

from fastapi import Depends
from sqlalchemy.orm import Session

from database import get_db
from schemas import TokenData
from utils.authentication import get_current_user, get_optional_user

DBDependency = Annotated[Session, Depends(get_db)]
UserDependency = Annotated[TokenData, Depends(get_current_user)]
OptionalUserDep = Annotated[Optional[TokenData], Depends(get_optional_user)]
