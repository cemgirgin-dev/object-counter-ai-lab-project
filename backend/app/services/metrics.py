"""Prometheus metrics for the object recognition backend."""

from __future__ import annotations

from typing import Any, Dict

from fastapi import Response
from prometheus_client import (
    CONTENT_TYPE_LATEST,
    Counter,
    Gauge,
    Histogram,
    Summary,
    generate_latest,
)

# Request metrics
REQUEST_COUNT = Counter(
    'http_requests_total', 
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

REQUEST_DURATION = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration in seconds',
    ['method', 'endpoint']
)

# Model performance metrics
MODEL_INFERENCE_TIME = Histogram(
    'model_inference_duration_seconds',
    'Model inference time in seconds',
    ['model_name', 'object_type']
)

MODEL_CONFIDENCE = Histogram(
    'model_confidence_score',
    'Model confidence score for predictions',
    ['object_type', 'model_name']
)

# Accuracy metrics (calculated from corrections)
ACCURACY_GAUGE = Gauge(
    'model_accuracy',
    'Model accuracy percentage',
    ['object_type']
)

PRECISION_GAUGE = Gauge(
    'model_precision',
    'Model precision percentage', 
    ['object_type']
)

RECALL_GAUGE = Gauge(
    'model_recall',
    'Model recall percentage',
    ['object_type']
)

# Image processing metrics
IMAGE_RESOLUTION = Histogram(
    'image_resolution_pixels',
    'Image resolution in pixels',
    ['dimension']  # width, height
)

OBJECT_COUNT = Histogram(
    'objects_detected_count',
    'Number of objects detected',
    ['object_type']
)

SEGMENTS_FOUND = Histogram(
    'segments_found_count',
    'Number of segments found in image',
    ['object_type']
)

OBJECT_TYPES_FOUND = Histogram(
    'object_types_detected_count',
    'Number of different object types found',
    ['object_type']
)

# System metrics
ACTIVE_REQUESTS = Gauge(
    'active_requests',
    'Number of active requests'
)

MODEL_LOAD_TIME = Histogram(
    'model_load_duration_seconds',
    'Time taken to load models',
    ['model_name']
)

# Response time summary
RESPONSE_TIME = Summary(
    'api_response_time_seconds',
    'API response time in seconds',
    ['endpoint']
)

# Safety metrics
SAFETY_BLOCKS = Counter(
    'safety_blocks_total',
    'Total number of requests blocked by safety system',
    ['object_type', 'reason']
)

SAFETY_CONFIDENCE = Histogram(
    'safety_detection_confidence',
    'Confidence score for safety detections',
    ['object_type', 'reason']
)

class MetricsCollector:
    """Collects and manages metrics for the AI Object Counter."""

    def __init__(self):
        self.corrections_data = {}  # Store correction data for accuracy calculation
        
    def record_request(self, method: str, endpoint: str, status_code: int, duration: float):
        """Record HTTP request metrics"""
        REQUEST_COUNT.labels(method=method, endpoint=endpoint, status=status_code).inc()
        REQUEST_DURATION.labels(method=method, endpoint=endpoint).observe(duration)
        
    def record_model_inference(self, model_name: str, object_type: str, duration: float, confidence: float):
        """Record model inference metrics"""
        MODEL_INFERENCE_TIME.labels(model_name=model_name, object_type=object_type).observe(duration)
        MODEL_CONFIDENCE.labels(object_type=object_type, model_name=model_name).observe(confidence)
        
    def record_image_metrics(self, image_data: bytes, object_type: str, detected_objects: list, segments_count: int):
        """Record image processing metrics"""
        from PIL import Image
        import io
        
        # Get image dimensions
        image = Image.open(io.BytesIO(image_data))
        width, height = image.size
        
        IMAGE_RESOLUTION.labels(dimension='width').observe(width)
        IMAGE_RESOLUTION.labels(dimension='height').observe(height)
        
        # Record object counts
        OBJECT_COUNT.labels(object_type=object_type).observe(len(detected_objects))
        SEGMENTS_FOUND.labels(object_type=object_type).observe(segments_count)
        
        # Count unique object types
        unique_types = len(set(detected_objects))
        OBJECT_TYPES_FOUND.labels(object_type=object_type).observe(unique_types)
        
    def record_correction(self, result_id: str, object_type: str, predicted_count: int, corrected_count: int):
        """Record user correction for accuracy calculation"""
        if object_type not in self.corrections_data:
            self.corrections_data[object_type] = {'predictions': [], 'corrections': []}
            
        self.corrections_data[object_type]['predictions'].append(predicted_count)
        self.corrections_data[object_type]['corrections'].append(corrected_count)
        
        # Calculate and update accuracy metrics
        self._update_accuracy_metrics(object_type)
        
    def _update_accuracy_metrics(self, object_type: str):
        """Calculate accuracy, precision, and recall from corrections"""
        if object_type not in self.corrections_data:
            return
            
        predictions = self.corrections_data[object_type]['predictions']
        corrections = self.corrections_data[object_type]['corrections']
        
        if len(predictions) < 2:  # Need at least 2 samples
            return
            
        # Calculate accuracy (exact matches)
        exact_matches = sum(1 for p, c in zip(predictions, corrections) if p == c)
        accuracy = (exact_matches / len(predictions)) * 100
        ACCURACY_GAUGE.labels(object_type=object_type).set(accuracy)
        
        # Calculate precision (how many of our predictions were correct)
        # For counting tasks, precision = accuracy
        PRECISION_GAUGE.labels(object_type=object_type).set(accuracy)
        
        # Calculate recall (how many correct counts we found)
        # For counting tasks, recall = accuracy  
        RECALL_GAUGE.labels(object_type=object_type).set(accuracy)
        
    def record_response_time(self, endpoint: str, duration: float):
        """Record API response time"""
        RESPONSE_TIME.labels(endpoint=endpoint).observe(duration)
        
    def increment_active_requests(self):
        """Increment active requests counter"""
        ACTIVE_REQUESTS.inc()
        
    def decrement_active_requests(self):
        """Decrement active requests counter"""
        ACTIVE_REQUESTS.dec()
        
    def record_safety_block(self, object_type: str, reason: str, confidence: float):
        """Record safety system block"""
        SAFETY_BLOCKS.labels(object_type=object_type, reason=reason).inc()
        SAFETY_CONFIDENCE.labels(object_type=object_type, reason=reason).observe(confidence)
        
    def get_metrics(self) -> str:
        """Get metrics in OpenMetrics format"""
        return generate_latest()

# Global metrics collector instance
metrics_collector = MetricsCollector()

def get_metrics_response() -> Response:
    """Get metrics response for /metrics endpoint"""
    data = metrics_collector.get_metrics()
    return Response(content=data, media_type=CONTENT_TYPE_LATEST)
