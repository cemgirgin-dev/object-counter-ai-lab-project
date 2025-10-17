#!/usr/bin/env python3

import sys
import os
sys.path.append('backend')

from safety_pipeline import SafetyPipeline
from PIL import Image
import io

print("=== TESTING SAFETY MECHANISM ===")

# Create safety pipeline
print("1. Creating safety pipeline...")
safety = SafetyPipeline()

# Test with tank image
print("2. Loading tank image...")
with open('test_tank.jpg', 'rb') as f:
    image_data = f.read()

print(f"   Image data size: {len(image_data)} bytes")

# Test the safety check
print("3. Running safety check...")
result = safety.check_safety(image_data, 'person')
print(f"   Safety result: {result}")

# Check if it's safe or blocked
if result.get('safe', False):
    print("   ❌ SAFETY CHECK FAILED - Image was allowed through!")
else:
    print("   ✅ SAFETY CHECK WORKED - Image was blocked!")

print("\n=== TESTING MILITARY DETECTION DIRECTLY ===")

# Test military detection directly
print("4. Testing military detection directly...")
image = Image.open(io.BytesIO(image_data))
print(f"   Image size: {image.size}")
print(f"   Image mode: {image.mode}")

try:
    detection_result = safety.model.detect_military_content(image, 'person')
    print(f"   Detection result: {detection_result}")
except Exception as e:
    print(f"   Error in military detection: {e}")
