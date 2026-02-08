from starlette import status

from schemas import ErrorCode, Status


class ServiceException(Exception):
    """Base class for every project exception."""

    STATUS_CODE: int = status.HTTP_500_INTERNAL_SERVER_ERROR
    STATUS: Status = Status.ERROR
    CODE: ErrorCode = ErrorCode.GENERIC_ERROR
    DETAIL: str = "Internal server error"

    def __init__(
        self,
        detail: str | None = None,
        status_code: int | None = None,
        status: Status | None = None,
        code: ErrorCode | None = None,
        headers: dict[str, str] | None = None,
    ) -> None:
        self.status_code = status_code or self.STATUS_CODE
        self.status = status or self.STATUS
        self.code = code or self.CODE
        self.detail = detail or self.DETAIL
        self.headers = headers

        super().__init__(self.detail)


class BadRequest(ServiceException):
    STATUS_CODE = status.HTTP_400_BAD_REQUEST
    DETAIL = "Bad request"


class Unauthorized(ServiceException):
    STATUS_CODE = status.HTTP_401_UNAUTHORIZED
    CODE = ErrorCode.UNAUTHORIZED
    DETAIL = "Unauthorized"


class Forbidden(ServiceException):
    STATUS_CODE = status.HTTP_403_FORBIDDEN
    CODE = ErrorCode.PERMISSION_DENIED
    DETAIL = "Forbidden"


class NotFound(ServiceException):
    STATUS_CODE = status.HTTP_404_NOT_FOUND
    CODE = ErrorCode.NOT_FOUND
    DETAIL = "Not found"


class InternalServerError(ServiceException):
    pass
