from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class CountRequest(BaseModel):
    """Payload for requesting an object count."""

    object_type: str


class CountResponse(BaseModel):
    """Response returned after processing an image."""

    result_id: str
    object_type: str
    count: int
    confidence: float
    segmented_image_path: Optional[str] = None
    processing_time: Optional[float] = None


class CorrectionRequest(BaseModel):
    """Payload for user-provided corrections."""

    result_id: str
    corrected_count: int


class CountResult(BaseModel):
    """Object count result stored in the database."""

    result_id: str
    image_path: str
    object_type: str
    count: int
    corrected_count: Optional[int] = None
    confidence: float
    timestamp: datetime
    segmented_image_path: Optional[str] = None
