from typing import Annotated

from fastapi import Depends
from sqlalchemy.orm import Session

from database import get_db
from schemas import UserTokenPayload
from utils.authentication import get_current_user

DBDependency = Annotated[Session, Depends(get_db)]
UserDependency = Annotated[UserTokenPayload, Depends(get_current_user)]
# IDK if this is actually worth it
# OptionalUserDep = Annotated[Optional[UserTokenPayload], Depends(get_optional_user)]
