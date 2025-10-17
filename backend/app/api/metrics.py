"""Metrics and safety-related endpoints."""

from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException

from app.dependencies import get_safety_pipeline
from app.services.metrics import get_metrics_response


router = APIRouter(tags=["metrics"])


@router.get("/metrics")
async def metrics():
    return get_metrics_response()


@router.get("/api/safety-stats")
async def get_safety_statistics(safety_pipeline=Depends(get_safety_pipeline)):
    try:
        stats = safety_pipeline.get_safety_statistics()
        return {"safety_statistics": stats}
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Failed to get safety statistics: {exc}")
