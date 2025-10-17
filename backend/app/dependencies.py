"""Dependency providers for FastAPI routes."""

from __future__ import annotations

from functools import lru_cache

from app.core.config import settings
from app.services import (
    DatabaseManager,
    FewShotLearningPipeline,
    SafetyPipeline,
    YOLOObjectCounterPipeline,
    metrics_collector,
)


@lru_cache
def get_database_manager() -> DatabaseManager:
    return DatabaseManager(settings.database_path)


@lru_cache
def get_yolo_pipeline() -> YOLOObjectCounterPipeline:
    return YOLOObjectCounterPipeline()


@lru_cache
def get_safety_pipeline() -> SafetyPipeline:
    return SafetyPipeline()


@lru_cache
def get_few_shot_pipeline() -> FewShotLearningPipeline:
    return FewShotLearningPipeline()


def get_metrics_collector():
    return metrics_collector


__all__ = [
    "get_database_manager",
    "get_yolo_pipeline",
    "get_safety_pipeline",
    "get_few_shot_pipeline",
    "get_metrics_collector",
]
