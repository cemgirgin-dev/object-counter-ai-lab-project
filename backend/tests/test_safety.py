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
with open('backend/test_tank.jpg', 'rb') as f:
    image_data = f.read()

result = safety.check_safety(image_data, 'person')
print('Safety result:', result)
