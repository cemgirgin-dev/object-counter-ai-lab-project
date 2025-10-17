"""Utility endpoint for generating synthetic images."""

from __future__ import annotations

import sys
import time
from pathlib import Path

from fastapi import APIRouter, HTTPException

from app.core.config import settings

router = APIRouter(prefix="/api", tags=["generation"])


@router.post("/generate-images")
async def generate_images(request: dict | None = None):
    request = request or {}

    object_type = request.get("object_type", "cat")
    count = request.get("count", 3)
    blur_level = request.get("blur_level", 0.0)
    rotation_range = request.get("rotation_range", 0.0)
    noise_level = request.get("noise_level", 0.0)

    try:
        sys.path.append(str(settings.project_root))
        from tools.image_generator import AIImageGenerator  # pylint: disable=import-error

        generator = AIImageGenerator()
        images = generator.generate_test_images(
            object_type=object_type,
            count=count,
            background_type="random",
            blur_level=blur_level,
            rotation_range=(0, rotation_range),
            noise_level=noise_level,
        )

        output_dir = settings.generated_images_dir / f"test_images_{object_type}_{count}_{int(time.time())}"
        file_paths = generator.save_images(images, str(output_dir))

        generated_images = []
        for path in file_paths:
            relative_path = Path(path).resolve().relative_to(settings.project_root)
            generated_images.append(f"/static/{relative_path.as_posix()}")

        return {
            "success": True,
            "generated_images": generated_images,
            "object_type": object_type,
            "count": count,
            "parameters": {
                "blur_level": blur_level,
                "rotation_range": rotation_range,
                "noise_level": noise_level,
            },
        }
    except Exception as exc:  # pragma: no cover - defensive logging
        raise HTTPException(status_code=500, detail=f"Image generation failed: {exc}")
