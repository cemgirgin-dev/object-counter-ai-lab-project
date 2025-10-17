"""Endpoints for retrieving and correcting stored results."""

from __future__ import annotations

from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException

from app.dependencies import get_database_manager, get_metrics_collector
from app.models.schemas import CorrectionRequest

router = APIRouter(prefix="/api", tags=["results"])


@router.post("/correct")
async def correct_count(
    correction: CorrectionRequest,
    db_manager=Depends(get_database_manager),
    metrics_collector=Depends(get_metrics_collector),
):
    original_result = db_manager.get_result(correction.result_id)
    if not original_result:
        raise HTTPException(status_code=404, detail="Original result not found")

    db_manager.store_correction(
        result_id=correction.result_id,
        corrected_count=correction.corrected_count,
        timestamp=datetime.utcnow(),
    )

    metrics_collector.record_correction(
        result_id=correction.result_id,
        object_type=original_result["object_type"],
        predicted_count=original_result["count"],
        corrected_count=correction.corrected_count,
    )

    return {"message": "Correction submitted successfully", "result_id": correction.result_id}


@router.get("/results/{result_id}")
async def get_result(result_id: str, db_manager=Depends(get_database_manager)):
    result = db_manager.get_result(result_id)
    if not result:
        raise HTTPException(status_code=404, detail="Result not found")
    return result


@router.get("/results")
async def get_all_results(limit: int = 10, offset: int = 0, db_manager=Depends(get_database_manager)):
    results = db_manager.get_all_results(limit=limit, offset=offset)
    return {"results": results, "limit": limit, "offset": offset}
