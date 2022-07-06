from pydantic import BaseSettings


class Settings(BaseSettings):
    app_name: str = "Awesome API"
    debug: bool = False

    class Config:
        env_file = ".env"
