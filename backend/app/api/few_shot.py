"""Few-shot learning endpoints."""

from __future__ import annotations

import time
import uuid
from datetime import datetime
from typing import List

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile

from app.dependencies import (
    get_database_manager,
    get_few_shot_pipeline,
    get_metrics_collector,
    get_yolo_pipeline,
)
from app.models.schemas import CountResponse

router = APIRouter(prefix="/api", tags=["few-shot"])


@router.post("/learn-object")
async def learn_new_object_type(
    object_type: str = Form(...),
    files: List[UploadFile] = File(...),
    few_shot_pipeline=Depends(get_few_shot_pipeline),
):
    if not files or len(files) < 3:
        raise HTTPException(status_code=400, detail="At least 3 training images are required")

    training_images = [await file.read() for file in files]
    try:
        return few_shot_pipeline.learn_new_object_type(object_type, training_images)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Learning failed: {exc}")


@router.get("/learned-objects")
async def get_learned_objects(few_shot_pipeline=Depends(get_few_shot_pipeline)):
    return {"learned_object_types": few_shot_pipeline.get_learned_object_types()}


@router.get("/learned-objects/{object_type}")
async def get_learning_info(object_type: str, few_shot_pipeline=Depends(get_few_shot_pipeline)):
    info = few_shot_pipeline.get_learning_info(object_type)
    if not info:
        raise HTTPException(status_code=404, detail="Object type not found")
    return info


@router.delete("/learned-objects/{object_type}")
async def delete_learned_object_type(object_type: str, few_shot_pipeline=Depends(get_few_shot_pipeline)):
    if not few_shot_pipeline.delete_learned_object_type(object_type):
        raise HTTPException(status_code=404, detail="Object type not found")
    return {"message": f"Object type '{object_type}' deleted successfully"}


@router.post("/count-learned", response_model=CountResponse)
async def count_learned_objects(
    file: UploadFile = File(...),
    object_type: str = Form(...),
    few_shot_pipeline=Depends(get_few_shot_pipeline),
    db_manager=Depends(get_database_manager),
    yolo_pipeline=Depends(get_yolo_pipeline),
    metrics_collector=Depends(get_metrics_collector),
):
    start_time = time.time()
    metrics_collector.increment_active_requests()

    try:
        image_data = await file.read()
        result = few_shot_pipeline.detect_with_learned_model(image_data, object_type, yolo_pipeline)
        if not result.get("success", False):
            raise HTTPException(status_code=400, detail=result.get("error", "Few-shot detection failed"))

        result_id = str(uuid.uuid4())
        db_manager.store_count_result(
            result_id=result_id,
            image_path="",
            object_type=object_type,
            count=result["count"],
            confidence=result["confidence"],
            timestamp=datetime.utcnow(),
            segmented_image_path=result.get("segmented_image_path", ""),
        )

        total_time = time.time() - start_time
        metrics_collector.record_response_time("count_learned", total_time)

        return CountResponse(
            result_id=result_id,
            object_type=object_type,
            count=result["count"],
            confidence=result["confidence"],
            segmented_image_path=result.get("segmented_image_path"),
            processing_time=total_time,
        )
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Processing failed: {exc}")
    finally:
        metrics_collector.decrement_active_requests()
