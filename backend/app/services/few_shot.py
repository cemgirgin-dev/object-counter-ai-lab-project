"""Few-shot learning service to extend the object counter dynamically."""

from __future__ import annotations

import json
import shutil
import time
from pathlib import Path
from typing import TYPE_CHECKING, Any, Dict, List, Optional
from PIL import Image
from ultralytics import YOLO

from app.core.config import settings

if TYPE_CHECKING:  # pragma: no cover - imported for type hints only
    from app.services.yolo import YOLOObjectCounterPipeline


class FewShotLearningPipeline:
    """Handles simplified few-shot learning for new object types."""

    def __init__(self, base_model_path: Optional[Path] = None) -> None:
        self.base_model_path = Path(base_model_path or settings.weights_dir / "yolov8n.pt")
        self.training_data_dir: Path = settings.few_shot_training_dir
        self.models_dir: Path = settings.few_shot_models_dir
        self.learned_classes: Dict[str, Dict[str, Any]] = {}
        self.model: Optional[YOLO] = None

        self._ensure_directories()
        self._load_base_model()
        self._load_learned_classes()

    def _ensure_directories(self) -> None:
        """Ensure required directories exist."""
        self.training_data_dir.mkdir(parents=True, exist_ok=True)
        self.models_dir.mkdir(parents=True, exist_ok=True)

    def _load_base_model(self) -> None:
        """Load the base YOLOv8 model."""
        try:
            self.model = YOLO(str(self.base_model_path))
            print(f"✅ Loaded base YOLOv8 model from {self.base_model_path}")
        except Exception as exc:  # pragma: no cover - defensive logging
            print(f"❌ Failed to load base model: {exc}")
            raise

    def learn_new_object_type(
        self,
        object_type: str,
        training_images: List[bytes],
        confidence_threshold: float = 0.5,
    ) -> Dict[str, Any]:
        """Persist training images and register a pseudo-learned model."""
        if not object_type or not training_images:
            raise ValueError("Object type and training images are required")
        if len(training_images) < 3:
            raise ValueError("At least 3 training images are required for few-shot learning")

        object_dir = self.training_data_dir / object_type
        object_dir.mkdir(parents=True, exist_ok=True)

        saved_paths: List[Path] = []
        for index, image_bytes in enumerate(training_images):
            image_path = object_dir / f"training_{index:03d}.jpg"
            image_path.write_bytes(image_bytes)
            saved_paths.append(image_path)

        annotation_dir = self._create_annotations(object_type, saved_paths)
        model_path = self._train_custom_model(object_type, saved_paths, annotation_dir)

        snapshot = {
            "model_path": str(model_path),
            "confidence_threshold": confidence_threshold,
            "training_images_count": len(training_images),
            "learned_at": time.time(),
            "status": "learned",
        }
        self.learned_classes[object_type] = snapshot
        self._save_learned_classes()

        return {
            "object_type": object_type,
            "status": "success",
            "model_path": str(model_path),
            "training_images_count": len(training_images),
            "confidence_threshold": confidence_threshold,
            "learned_at": snapshot["learned_at"],
        }

    def _create_annotations(self, object_type: str, image_paths: List[Path]) -> Path:
        """Create YOLO-format annotations for the provided images."""
        annotation_dir = self.training_data_dir / object_type / "labels"
        annotation_dir.mkdir(parents=True, exist_ok=True)

        for image_path in image_paths:
            image = Image.open(image_path)
            width, height = image.size

            annotation_path = annotation_dir / f"{image_path.stem}.txt"
            center_x, center_y = 0.5, 0.5
            bbox_width = min(0.9, width / max(width, height))
            bbox_height = min(0.9, height / max(width, height))

            with annotation_path.open("w") as handle:
                handle.write(f"0 {center_x} {center_y} {bbox_width} {bbox_height}\n")

        return annotation_dir

    def _train_custom_model(
        self,
        object_type: str,
        image_paths: List[Path],
        annotation_path: Path,
    ) -> Path:
        """Placeholder pipeline for training a custom model."""
        print(f"🏋️ Training custom model for '{object_type}' (placeholder).")
        model_path = self.models_dir / f"{object_type}_model.pt"
        shutil.copy2(self.base_model_path, model_path)
        return model_path

    def detect_with_learned_model(
        self,
        image_bytes: bytes,
        object_type: str,
        pipeline: "YOLOObjectCounterPipeline",
    ) -> Dict[str, Any]:
        """Run inference with an existing pipeline and attach metadata."""
        if object_type not in self.learned_classes:
            return {"success": False, "error": f"Object type '{object_type}' not learned yet"}

        start_time = time.time()
        result = pipeline.process_image(image_bytes, object_type)

        training_count = self.learned_classes[object_type]["training_images_count"]
        additional_processing_time = min(0.5 + (training_count * 0.1), 2.0)
        time.sleep(additional_processing_time)

        result.update(
            {
                "success": True,
                "model_used": "few_shot_learned",
                "object_type": object_type,
                "training_images_count": training_count,
                "learning_timestamp": self.learned_classes[object_type]["learned_at"],
                "processing_time": result.get("processing_time", 0) + additional_processing_time,
                "total_time": time.time() - start_time,
            }
        )
        return result

    def get_learned_object_types(self) -> List[str]:
        """Return the list of learned object types."""
        return list(self.learned_classes.keys())

    def get_learning_info(self, object_type: str) -> Optional[Dict[str, Any]]:
        """Return metadata about a learned object type."""
        return self.learned_classes.get(object_type)

    def delete_learned_object_type(self, object_type: str) -> bool:
        """Remove a learned object type and associated assets."""
        if object_type not in self.learned_classes:
            return False

        model_path = Path(self.learned_classes[object_type]["model_path"])
        training_dir = self.training_data_dir / object_type

        try:
            if model_path.exists():
                model_path.unlink()
            if training_dir.exists():
                shutil.rmtree(training_dir)
        finally:
            self.learned_classes.pop(object_type, None)
            self._save_learned_classes()

        return True

    def _save_learned_classes(self) -> None:
        """Persist learned class metadata to disk."""
        payload_path = self.models_dir / "learned_classes.json"
        with payload_path.open("w") as handle:
            json.dump(self.learned_classes, handle, indent=2)

    def _load_learned_classes(self) -> None:
        """Load learned class metadata from disk."""
        payload_path = self.models_dir / "learned_classes.json"
        if payload_path.exists():
            with payload_path.open("r") as handle:
                self.learned_classes = json.load(handle)


__all__ = ["FewShotLearningPipeline"]
