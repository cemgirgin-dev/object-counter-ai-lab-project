"""Endpoints responsible for core object counting."""

from __future__ import annotations

import io
import time
import uuid
from datetime import datetime

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from fastapi.responses import JSONResponse
from PIL import Image

from app.core.config import settings
from app.core.constants import OBJECT_TYPES
from app.dependencies import (
    get_database_manager,
    get_metrics_collector,
    get_safety_pipeline,
    get_yolo_pipeline,
)
from app.models.schemas import CountResponse

router = APIRouter(prefix="/api", tags=["counting"])


@router.post("/count", response_model=CountResponse)
async def count_objects(
    file: UploadFile = File(...),
    object_type: str = Form(...),
    db_manager=Depends(get_database_manager),
    yolo_pipeline=Depends(get_yolo_pipeline),
    safety_pipeline=Depends(get_safety_pipeline),
    metrics_collector=Depends(get_metrics_collector),
):
    start_time = time.time()
    metrics_collector.increment_active_requests()

    try:
        image_data = await file.read()

        if not file.content_type or not file.content_type.startswith("image/"):
            filename = (file.filename or "").lower()
            if not any(filename.endswith(ext) for ext in [".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp"]):
                raise HTTPException(status_code=400, detail="File must be an image")

        if object_type not in OBJECT_TYPES:
            raise HTTPException(status_code=400, detail=f"Object type must be one of: {OBJECT_TYPES}")

        try:
            Image.open(io.BytesIO(image_data))
        except Exception as exc:
            raise HTTPException(status_code=400, detail=f"Invalid image file: {exc}")

        safety_result = safety_pipeline.check_safety(image_data, object_type, file.filename)
        if not safety_result.get("safe", True):
            metrics_collector.record_safety_block(
                object_type=object_type,
                reason=safety_result.get("reason", "blocked"),
                confidence=safety_result.get("confidence", 0.0),
            )
            return JSONResponse(
                status_code=403,
                content={
                    "error": "Safety check failed",
                    "reason": safety_result.get("reason"),
                    "safety_details": safety_result,
                },
            )

        result = yolo_pipeline.process_image(image_data, object_type)

        metrics_collector.record_model_inference(
            model_name="yolov8",
            object_type=object_type,
            duration=result.get("processing_time", 0),
            confidence=result.get("confidence", 0.0),
        )

        metrics_collector.record_image_metrics(
            image_data=image_data,
            object_type=object_type,
            detected_objects=result.get("detected_objects", []),
            segments_count=result.get("total_detections", 0),
        )

        upload_path = settings.uploads_dir / f"{uuid.uuid4()}_{file.filename or 'upload.jpg'}"
        upload_path.write_bytes(image_data)

        result_id = str(uuid.uuid4())
        db_manager.store_count_result(
            result_id=result_id,
            image_path=str(upload_path.relative_to(settings.project_root)),
            object_type=object_type,
            count=result["count"],
            confidence=result["confidence"],
            timestamp=datetime.utcnow(),
            segmented_image_path=result.get("segmented_image_path"),
        )

        total_time = time.time() - start_time
        metrics_collector.record_response_time("count", total_time)

        return CountResponse(
            result_id=result_id,
            object_type=object_type,
            count=result["count"],
            confidence=result["confidence"],
            segmented_image_path=result.get("segmented_image_path"),
            processing_time=result.get("processing_time", total_time),
        )

    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Processing failed: {exc}")
    finally:
        metrics_collector.decrement_active_requests()
