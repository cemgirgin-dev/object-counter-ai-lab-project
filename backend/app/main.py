"""Application entrypoint for the backend service."""

from __future__ import annotations

import time

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response
from fastapi.staticfiles import StaticFiles

from app.api import router as api_router
from app.core.config import settings
from app.dependencies import get_metrics_collector


def create_app() -> FastAPI:
    app = FastAPI(
        title="AI Object Counter API",
        description="API for counting objects in images using AI",
        version="1.0.0",
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.allowed_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.include_router(api_router)

    app.mount("/static", StaticFiles(directory=str(settings.project_root)), name="static")

    metrics_collector = get_metrics_collector()

    @app.middleware("http")
    async def metrics_middleware(request: Request, call_next):  # type: ignore[override]
        start_time = time.time()
        response: Response = await call_next(request)
        duration = time.time() - start_time

        metrics_collector.record_request(
            method=request.method,
            endpoint=request.url.path,
            status_code=response.status_code,
            duration=duration,
        )
        return response

    return app


app = create_app()


__all__ = ["app", "create_app"]
