from typing import Any

from sqlalchemy.orm import DeclarativeBase


class Base(DeclarativeBase):
    def to_dict(self) -> dict[str, Any]:
        return {
            field.name: getattr(self, field.name) for field in self.__table__.columns
        }

    def __repr__(self) -> str:
        return f"{self.__class__.__name__}({', '.join(f'{key}={value!r}' for key, value in self.to_dict().items())})>"
