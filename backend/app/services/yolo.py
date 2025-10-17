"""YOLOv8 inference pipeline used by the backend API."""

from __future__ import annotations

import gc
import io
import time
from pathlib import Path
from typing import Dict, List, Optional

import cv2
import numpy as np
import torch
from PIL import Image
from ultralytics import YOLO

from app.core.config import settings


class YOLOObjectCounterPipeline:
    """Wraps a YOLOv8 model with utilities for object counting."""

    def __init__(self, weights_path: Optional[Path] = None) -> None:
        self.device = self._get_optimal_device()
        self.model_path = Path(weights_path or settings.weights_dir / "yolov8s.pt")
        self.model: Optional[YOLO] = None
        self.model_loaded = False
        print(f"YOLO pipeline initialised on device: {self.device}")

    def _get_optimal_device(self) -> str:
        if torch.backends.mps.is_available():
            return "mps"
        if torch.cuda.is_available():
            return "cuda"
        return "cpu"

    def _load_model(self) -> None:
        if not self.model_loaded:
            print(f"Loading YOLOv8 model from {self.model_path}...")
            self.model = YOLO(str(self.model_path))
            self.model.to(self.device)
            self.model_loaded = True

    def _cleanup_memory(self) -> None:
        if torch.backends.mps.is_available():
            torch.mps.empty_cache()
        elif torch.cuda.is_available():
            torch.cuda.empty_cache()
        gc.collect()

    def process_image(self, image_data: bytes, object_type: str) -> Dict[str, object]:
        start_time = time.time()

        try:
            self._load_model()
            image = Image.open(io.BytesIO(image_data))
        except Exception as exc:
            return {"count": 0, "confidence": 0.0, "error": str(exc)}

        if image.mode != "RGB":
            image = image.convert("RGB")

        image = image.resize((640, 640), Image.Resampling.LANCZOS)
        image_array = np.array(image)

        if self.model is None:  # pragma: no cover - defensive guard
            return {"count": 0, "confidence": 0.0, "error": "YOLO model not loaded"}

        try:
            results = self.model(image_array, device=self.device, verbose=False)
        except Exception as exc:  # pragma: no cover - defensive logging
            return {"count": 0, "confidence": 0.0, "error": str(exc)}

        detections: List[Dict[str, object]] = []
        target_count = 0
        confidence_scores: List[float] = []

        for result in results:
            boxes = result.boxes
            if boxes is None:
                continue
            for box in boxes:
                class_id = int(box.cls[0])
                confidence = float(box.conf[0])
                detected_type = self._map_coco_to_custom(class_id)

                if detected_type == object_type.lower() and confidence >= 0.15:
                    target_count += 1
                    confidence_scores.append(confidence)
                elif (
                    self._is_animal_type(detected_type)
                    and self._is_animal_type(object_type.lower())
                    and confidence >= 0.3
                ):
                    target_count += 1
                    confidence_scores.append(confidence * 0.8)

                detections.append(
                    {
                        "class": detected_type,
                        "confidence": confidence,
                        "bbox": box.xyxy[0].tolist(),
                    }
                )

        avg_confidence = float(np.mean(confidence_scores)) if confidence_scores else 0.0
        processing_time = time.time() - start_time

        segmented_image_path = None
        if target_count > 0:
            segmented_image_path = self._save_segmented_image(image_array, detections, object_type)

        self._cleanup_memory()

        return {
            "count": target_count,
            "confidence": round(avg_confidence, 3),
            "segmented_image_path": segmented_image_path,
            "processing_time": round(processing_time, 3),
            "total_detections": len(detections),
            "detected_objects": [d["class"] for d in detections],
            "target_object_type": object_type,
        }

    def _save_segmented_image(
        self,
        image_array: np.ndarray,
        detections: List[Dict[str, object]],
        object_type: str,
    ) -> Optional[str]:
        try:
            target_dir = settings.segmented_images_dir
            target_dir.mkdir(parents=True, exist_ok=True)

            image_with_boxes = image_array.copy()
            for detection in detections:
                if detection["class"] != object_type.lower():
                    continue
                bbox = detection["bbox"]
                x1, y1, x2, y2 = map(int, bbox)
                cv2.rectangle(image_with_boxes, (x1, y1), (x2, y2), (0, 255, 0), 2)
                cv2.putText(
                    image_with_boxes,
                    f"{detection['class']}: {detection['confidence']:.2f}",
                    (x1, max(10, y1 - 10)),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.5,
                    (0, 255, 0),
                    1,
                )

            timestamp = int(time.time())
            filename = target_dir / f"yolo_{object_type}_{timestamp}.jpg"
            cv2.imwrite(str(filename), cv2.cvtColor(image_with_boxes, cv2.COLOR_RGB2BGR))

            return str(filename.relative_to(settings.project_root))
        except Exception as exc:  # pragma: no cover - defensive logging
            print(f"Error saving segmented image: {exc}")
            return None

    def _is_animal_type(self, object_type: str) -> bool:
        animal_types = {
            "cat",
            "dog",
            "horse",
            "sheep",
            "cow",
            "elephant",
            "bear",
            "zebra",
            "giraffe",
        }
        return object_type.lower() in animal_types

    def _map_coco_to_custom(self, class_id: int) -> str:
        mapping = {
            0: "person",
            2: "car",
            3: "car",
            5: "car",
            7: "car",
            15: "cat",
            16: "dog",
            17: "horse",
            18: "sheep",
            19: "cow",
            20: "elephant",
            21: "bear",
            22: "zebra",
            23: "giraffe",
            24: "backpack",
            25: "umbrella",
            26: "handbag",
            27: "tie",
            28: "suitcase",
            29: "frisbee",
            30: "skis",
            31: "snowboard",
            32: "sports ball",
            33: "kite",
            34: "baseball bat",
            35: "baseball glove",
            36: "skateboard",
            37: "surfboard",
            38: "tennis racket",
            39: "bottle",
            40: "wine glass",
            41: "cup",
            42: "fork",
            43: "knife",
            44: "spoon",
            45: "bowl",
            46: "banana",
            47: "apple",
            48: "sandwich",
            49: "orange",
            50: "broccoli",
            51: "carrot",
            52: "hot dog",
            53: "pizza",
            54: "donut",
            55: "cake",
            56: "chair",
            57: "couch",
            58: "potted plant",
            59: "bed",
            60: "dining table",
            61: "toilet",
            62: "tv",
            63: "laptop",
            64: "mouse",
            65: "remote",
            66: "keyboard",
            67: "cell phone",
            68: "microwave",
            69: "oven",
            70: "toaster",
            71: "sink",
            72: "refrigerator",
            73: "book",
            74: "clock",
            75: "vase",
            76: "scissors",
            77: "teddy bear",
            78: "hair drier",
            79: "toothbrush",
        }
        return mapping.get(class_id, "other")


__all__ = ["YOLOObjectCounterPipeline"]
