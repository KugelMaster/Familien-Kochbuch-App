import logging
from pathlib import Path

from pydantic import computed_field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

_logger = logging.getLogger("uvicorn.error")


class Settings(BaseSettings):
    # Database
    DB_USERNAME: str = "cookbook"
    DB_PASSWORD: str = "mysecretpassword"
    DB_DOMAIN: str = "127.0.0.1"
    DB_PORT: str = "5432"
    DB_NAME: str = "cookbook"

    @computed_field
    @property
    def DATABASE_URL(self) -> str:
        return f"postgresql://{self.DB_USERNAME}:{self.DB_PASSWORD}@{self.DB_DOMAIN}:{self.DB_PORT}/{self.DB_NAME}"

    # Images
    IMAGE_DIR_RECIPES: Path = Path("/var/family-cookbook-api/images/recipes")

    # Authentication
    JWT_SECRET_KEY: str = "please-set-the-jwt-secret-key-in-the-env-file-thank-you"
    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRE_MINUTES: int = 60  # Currently not in use

    # Debugging
    DEBUG: bool = True

    @field_validator("IMAGE_DIR_RECIPES")
    @classmethod
    def check_dir_exists(cls, v: Path) -> Path:
        if not v.exists():
            v.mkdir(parents=True, exist_ok=True)
            _logger.info(f"Directory {v} created.")
        return v

    @field_validator("JWT_SECRET_KEY")
    @classmethod
    def warning_for_secret_key(cls, v: str) -> str:
        if v == "please-set-the-jwt-secret-key-in-the-env-file-thank-you":
            _logger.warning("JWT_SECRET_KEY wasn't set!")
        return v

    model_config = SettingsConfigDict(env_file="fastapi.env", env_file_encoding="utf-8")


# Maybe use LRU Caching?
config = Settings()
