"""Backend package exposing the FastAPI app factory."""

from app.main import app, create_app

__all__ = ["app", "create_app"]
