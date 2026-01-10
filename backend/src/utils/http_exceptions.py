from typing import Any

from fastapi import HTTPException
from starlette import status


class ServiceException(HTTPException):
    """Basis class for every project exception."""

    STATUS_CODE = status.HTTP_500_INTERNAL_SERVER_ERROR
    DETAIL = "Internal server error"

    def __init__(
        self, detail: Any = None, headers: dict[str, str] | None = None
    ) -> None:
        super().__init__(self.STATUS_CODE, detail or self.DETAIL, headers)


class BadRequest(ServiceException):
    STATUS_CODE = status.HTTP_400_BAD_REQUEST
    DETAIL = "Bad request"


class Unauthorized(ServiceException):
    STATUS_CODE = status.HTTP_401_UNAUTHORIZED
    DETAIL = "Unauthorized"


class Forbidden(ServiceException):
    STATUS_CODE = status.HTTP_403_FORBIDDEN
    DETAIL = "Forbidden"


class NotFound(ServiceException):
    STATUS_CODE = status.HTTP_404_NOT_FOUND
    DETAIL = "Not found"


class InternalServerError(ServiceException):
    pass
