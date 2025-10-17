"""Service layer exports."""

from .database import DatabaseManager
from .few_shot import FewShotLearningPipeline
from .metrics import MetricsCollector, get_metrics_response, metrics_collector
from .safety import MilitaryVehicleDetector, SafetyPipeline
from .yolo import YOLOObjectCounterPipeline

__all__ = [
    "DatabaseManager",
    "FewShotLearningPipeline",
    "MetricsCollector",
    "YOLOObjectCounterPipeline",
    "SafetyPipeline",
    "MilitaryVehicleDetector",
    "metrics_collector",
    "get_metrics_response",
]
