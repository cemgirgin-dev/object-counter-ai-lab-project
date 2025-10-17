#!/usr/bin/env python3

from PIL import Image
import sys
sys.path.append('backend')

def calculate_brightness(image):
    """Calculate average brightness of an image"""
    # Convert to grayscale
    gray_image = image.convert('L')
    
    # Get pixel data
    pixels = list(gray_image.getdata())
    
    # Calculate average brightness (0-255 scale, normalized to 0-1)
    avg_brightness = sum(pixels) / len(pixels) / 255.0
    
    return avg_brightness

# Test tank image
print("=== TANK IMAGE ANALYSIS ===")
tank_image = Image.open('backend/test_tank.jpg')
print(f"Size: {tank_image.size}")
print(f"Mode: {tank_image.mode}")
aspect_ratio = tank_image.size[0] / tank_image.size[1]
brightness = calculate_brightness(tank_image)
print(f"Aspect ratio: {aspect_ratio:.2f}")
print(f"Brightness: {brightness:.3f}")
print(f"Total pixels: {tank_image.size[0] * tank_image.size[1]}")

print("\n=== REGULAR IMAGE ANALYSIS ===")
regular_image = Image.open('test_image.jpg')
print(f"Size: {regular_image.size}")
print(f"Mode: {regular_image.mode}")
aspect_ratio = regular_image.size[0] / regular_image.size[1]
brightness = calculate_brightness(regular_image)
print(f"Aspect ratio: {aspect_ratio:.2f}")
print(f"Brightness: {brightness:.3f}")
print(f"Total pixels: {regular_image.size[0] * regular_image.size[1]}")
