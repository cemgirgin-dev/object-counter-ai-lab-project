#!/usr/bin/env python3

import sys
import os
sys.path.append('backend')

from safety_pipeline import SafetyPipeline

# Create safety pipeline
print("Creating safety pipeline...")
safety = SafetyPipeline()

# Test with tank image
print("Testing with tank image...")
with open('backend/test_tank.jpg', 'rb') as f:
    image_data = f.read()

result = safety.check_safety(image_data, 'person')
print('Safety result for person:', result)

# Test with tank image and tank object type
print("\nTesting with tank image and tank object type...")
result2 = safety.check_safety(image_data, 'tank')
print('Safety result for tank:', result2)
