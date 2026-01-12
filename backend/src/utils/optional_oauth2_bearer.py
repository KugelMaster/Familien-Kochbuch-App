from typing import Optional

from fastapi import HTTPException, Request
from fastapi.security import OAuth2PasswordBearer
from starlette import status


class OptionalOAuth2PasswordBearer(OAuth2PasswordBearer):
    async def __call__(self, request: Request) -> Optional[str]:
        try:
            return await super().__call__(request)
        except HTTPException as e:
            if e.status_code == status.HTTP_401_UNAUTHORIZED:
                return None
            raise e
