from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    APP_NAME: str = "Дача"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False

    DATABASE_URL: str
    REDIS_URL: str = "redis://localhost:6379/0"

    SECRET_KEY: str
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30
    ALGORITHM: str = "HS256"

    # Принимаем как строку через запятую, чтобы pydantic-settings
    # не пытался парсить .env как JSON. Список получаем через свойство ниже.
    ALLOWED_ORIGINS: str = "http://localhost:3000"

    UPLOAD_DIR: str = "/app/uploads"
    MAX_FILE_SIZE_MB: int = 10

    TELEGRAM_BOT_TOKEN: str = ""
    OPENWEATHER_API_KEY: str = ""

    @property
    def allowed_origins_list(self) -> list[str]:
        """Список origin'ов для CORSMiddleware."""
        return [
            item.strip()
            for item in self.ALLOWED_ORIGINS.split(",")
            if item.strip()
        ]

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()