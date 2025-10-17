"""Health and miscellaneous informational endpoints."""

from __future__ import annotations

from datetime import datetime

from fastapi import APIRouter

from app.core.constants import OBJECT_TYPES


router = APIRouter(tags=["health"])


@router.get("/")
async def root():
    return {"message": "AI Object Counter API", "version": "1.0.0"}


@router.get("/health")
async def health_check():
    return {"status": "healthy", "timestamp": datetime.utcnow().isoformat()}


@router.get("/test")
async def test_endpoint():
    return {"message": "Test endpoint working", "ml_pipeline": "YOLOv8 Object Counter"}


@router.get("/object-types")
async def get_object_types():
    return {"object_types": OBJECT_TYPES}
