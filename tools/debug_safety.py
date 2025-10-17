#!/usr/bin/env python3

import sys
import os
sys.path.append('backend')

from safety_pipeline import SafetyPipeline
from PIL import Image
import io

# Create safety pipeline
print("Creating safety pipeline...")
safety = SafetyPipeline()

# Test with tank image
print("Testing with tank image...")
with open('test_tank.jpg', 'rb') as f:
    image_data = f.read()

print(f"Image data size: {len(image_data)} bytes")

# Test the safety check
result = safety.check_safety(image_data, 'person')
print('Safety result:', result)

# Test the military detection directly
print("\nTesting military detection directly...")
image = Image.open(io.BytesIO(image_data))
print(f"Image size: {image.size}")
print(f"Image mode: {image.mode}")

detection_result = safety.model.detect_military_content(image, 'person')
print('Detection result:', detection_result)
