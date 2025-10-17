"""API routers for the object recognition backend."""

from fastapi import APIRouter

from . import counting, few_shot, generation, health, metrics, results

router = APIRouter()
router.include_router(health.router)
router.include_router(metrics.router)
router.include_router(counting.router)
router.include_router(results.router)
router.include_router(few_shot.router)
router.include_router(generation.router)

__all__ = ["router"]
