import pytest
from fastapi.testclient import TestClient

from backend import app

client = TestClient(app)

def test_root_endpoint():
    """Test the root endpoint"""
    response = client.get("/")
    assert response.status_code == 200
    assert "AI Object Counter API" in response.json()["message"]

def test_health_check():
    """Test the health check endpoint"""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

def test_get_object_types():
    """Test getting available object types"""
    response = client.get("/object-types")
    assert response.status_code == 200
    assert "object_types" in response.json()
    assert len(response.json()["object_types"]) > 0

def test_count_objects_invalid_file_type():
    """Test count endpoint with invalid file type"""
    files = {"file": ("test.txt", b"not an image", "text/plain")}
    data = {"object_type": "car"}
    
    response = client.post("/api/count", files=files, data=data)
    assert response.status_code == 400
    assert "File must be an image" in response.json()["detail"]

def test_count_objects_invalid_object_type():
    """Test count endpoint with invalid object type"""
    files = {"file": ("test.jpg", b"fake image data", "image/jpeg")}
    data = {"object_type": "invalid_type"}
    
    response = client.post("/api/count", files=files, data=data)
    assert response.status_code == 400
    assert "Object type must be one of" in response.json()["detail"]

def test_correct_count_missing_result_id():
    """Test correction endpoint with missing result ID"""
    correction_data = {"result_id": "non-existent", "corrected_count": 5}

    response = client.post("/api/correct", json=correction_data)
    assert response.status_code == 404

def test_get_nonexistent_result():
    """Test getting a result that doesn't exist"""
    response = client.get("/api/results/nonexistent-id")
    assert response.status_code == 404
    assert "Result not found" in response.json()["detail"]

def test_get_all_results():
    """Test getting all results"""
    response = client.get("/api/results")
    assert response.status_code == 200
    assert "results" in response.json()
    assert "limit" in response.json()
    assert "offset" in response.json()
