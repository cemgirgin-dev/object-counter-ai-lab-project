"""
AI Image Generator for Object Counter Testing
Generates test images with configurable objects, backgrounds, and augmentations
"""
import requests
import json
import time
import random
import os
from PIL import Image, ImageFilter, ImageEnhance, ImageDraw
import io
import base64
from typing import List, Dict, Any, Optional
import argparse
from pathlib import Path

class AIImageGenerator:
    """Generates test images using AI endpoint and local augmentation"""
    
    def __init__(self, ai_endpoint: str = "https://llm-web.aieng.fim.uni-passau.de", api_key: str = None):
        self.ai_endpoint = ai_endpoint
        self.api_key = api_key
        self.session = requests.Session()
        
    def generate_ai_image(self, prompt: str, width: int = 512, height: int = 512) -> Optional[Image.Image]:
        """Generate image using AI endpoint"""
        try:
            # This is a placeholder - you'll need to get actual API credentials from TAs
            # and implement the proper API call based on the endpoint documentation
            
            print(f"🤖 Generating AI image with prompt: '{prompt}'")
            print("⚠️  Note: AI endpoint integration requires credentials from TAs")
            
            # For now, create a placeholder image
            return self._create_placeholder_image(prompt, width, height)
            
        except Exception as e:
            print(f"❌ AI image generation failed: {e}")
            return None
    
    def _create_placeholder_image(self, prompt: str, width: int, height: int) -> Image.Image:
        """Create a realistic placeholder image based on the prompt"""
        # Create a random colored background
        colors = [
            (135, 206, 235),  # Sky blue
            (144, 238, 144),  # Light green
            (255, 182, 193),  # Light pink
            (255, 255, 224),  # Light yellow
            (230, 230, 250),  # Lavender
        ]
        bg_color = random.choice(colors)
        
        # Create image with background
        image = Image.new('RGB', (width, height), bg_color)
        draw = ImageDraw.Draw(image)
        
        # Draw objects based on the prompt
        num_objects = random.randint(1, 4)
        for _ in range(num_objects):
            x = random.randint(50, width - 50)
            y = random.randint(50, height - 50)
            size = random.randint(40, 100)
            
            # Draw different shapes based on object type
            prompt_lower = prompt.lower()
            if 'car' in prompt_lower:
                self._draw_car(draw, x, y, size)
            elif 'cat' in prompt_lower:
                self._draw_cat(draw, x, y, size)
            elif 'dog' in prompt_lower:
                self._draw_dog(draw, x, y, size)
            elif 'person' in prompt_lower:
                self._draw_person(draw, x, y, size)
            elif 'tree' in prompt_lower:
                self._draw_tree(draw, x, y, size)
            else:
                # Default to circle for unknown objects
                draw.ellipse([x - size//2, y - size//2, x + size//2, y + size//2], 
                            fill=(255, 255, 255, 128), outline=(0, 0, 0, 255))
        
        # Add text label
        try:
            draw.text((10, 10), f"Placeholder: {prompt}", fill=(0, 0, 0))
        except:
            pass  # Skip text if font not available
            
        return image
    
    def generate_test_images(self, 
                           object_type: str,
                           count: int = 5,
                           background_type: str = "random",
                           blur_level: float = 0.0,
                           rotation_range: tuple = (0, 0),
                           noise_level: float = 0.0,
                           width: int = 512,
                           height: int = 512) -> List[Image.Image]:
        """Generate multiple test images with specified parameters"""
        
        images = []
        
        for i in range(count):
            print(f"🎨 Generating image {i+1}/{count} for '{object_type}'")
            
            # Generate base image
            prompt = f"{object_type} on {background_type} background"
            base_image = self.generate_ai_image(prompt, width, height)
            
            if base_image is None:
                continue
                
            # Apply augmentations
            augmented_image = self._apply_augmentations(
                base_image, blur_level, rotation_range, noise_level
            )
            
            images.append(augmented_image)
            
        return images
    
    def _apply_augmentations(self, 
                           image: Image.Image,
                           blur_level: float,
                           rotation_range: tuple,
                           noise_level: float) -> Image.Image:
        """Apply various augmentations to the image"""
        
        # Apply blur
        if blur_level > 0:
            blur_radius = int(blur_level * 10)  # Scale to 0-10 radius
            image = image.filter(ImageFilter.GaussianBlur(radius=blur_radius))
        
        # Apply rotation
        if len(rotation_range) == 2 and rotation_range[0] != rotation_range[1]:
            rotation_angle = random.uniform(rotation_range[0], rotation_range[1])
            image = image.rotate(rotation_angle, expand=True)
        
        # Apply noise
        if noise_level > 0:
            image = self._add_noise(image, noise_level)
        
        return image
    
    def _add_noise(self, image: Image.Image, noise_level: float) -> Image.Image:
        """Add random noise to the image"""
        import numpy as np
        
        # Convert to numpy array
        img_array = np.array(image)
        
        # Generate noise
        noise = np.random.normal(0, noise_level * 25, img_array.shape)
        
        # Add noise and clip values
        noisy_array = np.clip(img_array + noise, 0, 255).astype(np.uint8)
        
        return Image.fromarray(noisy_array)
    
    def save_images(self, images: List[Image.Image], output_dir: str = "backend/data/generated_images") -> List[str]:
        """Save images to disk and return file paths"""
        output_path = Path(output_dir)
        output_path.mkdir(parents=True, exist_ok=True)

        file_paths = []
        timestamp = int(time.time())

        for i, image in enumerate(images):
            filename = f"generated_{timestamp}_{i:03d}.jpg"
            filepath = output_path / filename
            image.save(filepath, "JPEG", quality=85)
            file_paths.append(str(filepath))
            print(f"💾 Saved: {filepath}")

        return file_paths
    
    def _draw_car(self, draw, x, y, size):
        """Draw a simple car shape"""
        # Car body (rectangle)
        car_width = size
        car_height = size // 2
        draw.rectangle([x - car_width//2, y - car_height//2, x + car_width//2, y + car_height//2], 
                      fill=(100, 100, 100), outline=(0, 0, 0))
        
        # Wheels
        wheel_radius = size // 8
        draw.ellipse([x - car_width//2 + size//6, y + car_height//2 - wheel_radius, 
                     x - car_width//2 + size//6 + wheel_radius*2, y + car_height//2 + wheel_radius], 
                    fill=(50, 50, 50))
        draw.ellipse([x + car_width//2 - size//6 - wheel_radius*2, y + car_height//2 - wheel_radius, 
                     x + car_width//2 - size//6, y + car_height//2 + wheel_radius], 
                    fill=(50, 50, 50))
    
    def _draw_cat(self, draw, x, y, size):
        """Draw a simple cat shape"""
        # Cat body (oval)
        body_width = size
        body_height = size * 3 // 4
        draw.ellipse([x - body_width//2, y - body_height//2, x + body_width//2, y + body_height//2], 
                    fill=(255, 165, 0), outline=(0, 0, 0))  # Orange cat
        
        # Cat head (circle)
        head_radius = size // 3
        draw.ellipse([x - head_radius, y - body_height//2 - head_radius, 
                     x + head_radius, y - body_height//2 + head_radius], 
                    fill=(255, 165, 0), outline=(0, 0, 0))
        
        # Ears
        ear_size = size // 8
        draw.polygon([(x - head_radius//2, y - body_height//2 - head_radius), 
                     (x - head_radius//2 - ear_size, y - body_height//2 - head_radius - ear_size),
                     (x - head_radius//2 + ear_size, y - body_height//2 - head_radius - ear_size)], 
                    fill=(255, 165, 0), outline=(0, 0, 0))
        draw.polygon([(x + head_radius//2, y - body_height//2 - head_radius), 
                     (x + head_radius//2 - ear_size, y - body_height//2 - head_radius - ear_size),
                     (x + head_radius//2 + ear_size, y - body_height//2 - head_radius - ear_size)], 
                    fill=(255, 165, 0), outline=(0, 0, 0))
    
    def _draw_dog(self, draw, x, y, size):
        """Draw a simple dog shape"""
        # Dog body (oval)
        body_width = size
        body_height = size * 3 // 4
        draw.ellipse([x - body_width//2, y - body_height//2, x + body_width//2, y + body_height//2], 
                    fill=(139, 69, 19), outline=(0, 0, 0))  # Brown dog
        
        # Dog head (circle)
        head_radius = size // 3
        draw.ellipse([x - head_radius, y - body_height//2 - head_radius, 
                     x + head_radius, y - body_height//2 + head_radius], 
                    fill=(139, 69, 19), outline=(0, 0, 0))
        
        # Ears (floppy)
        ear_width = size // 4
        ear_height = size // 3
        draw.ellipse([x - head_radius - ear_width//2, y - body_height//2 - head_radius, 
                     x - head_radius + ear_width//2, y - body_height//2 - head_radius + ear_height], 
                    fill=(139, 69, 19), outline=(0, 0, 0))
        draw.ellipse([x + head_radius - ear_width//2, y - body_height//2 - head_radius, 
                     x + head_radius + ear_width//2, y - body_height//2 - head_radius + ear_height], 
                    fill=(139, 69, 19), outline=(0, 0, 0))
    
    def _draw_person(self, draw, x, y, size):
        """Draw a simple person shape"""
        # Head (circle)
        head_radius = size // 4
        draw.ellipse([x - head_radius, y - size//2, x + head_radius, y - size//2 + head_radius*2], 
                    fill=(255, 220, 177), outline=(0, 0, 0))  # Skin color
        
        # Body (rectangle)
        body_width = size // 3
        body_height = size // 2
        draw.rectangle([x - body_width//2, y - size//2 + head_radius*2, 
                       x + body_width//2, y - size//2 + head_radius*2 + body_height], 
                      fill=(0, 0, 255), outline=(0, 0, 0))  # Blue shirt
        
        # Arms
        arm_width = size // 8
        arm_height = size // 3
        draw.rectangle([x - body_width//2 - arm_width, y - size//2 + head_radius*2 + size//8, 
                       x - body_width//2, y - size//2 + head_radius*2 + size//8 + arm_height], 
                      fill=(255, 220, 177), outline=(0, 0, 0))
        draw.rectangle([x + body_width//2, y - size//2 + head_radius*2 + size//8, 
                       x + body_width//2 + arm_width, y - size//2 + head_radius*2 + size//8 + arm_height], 
                      fill=(255, 220, 177), outline=(0, 0, 0))
        
        # Legs
        leg_width = size // 6
        leg_height = size // 3
        draw.rectangle([x - leg_width, y - size//2 + head_radius*2 + body_height, 
                       x, y - size//2 + head_radius*2 + body_height + leg_height], 
                      fill=(0, 0, 0), outline=(0, 0, 0))  # Black pants
        draw.rectangle([x, y - size//2 + head_radius*2 + body_height, 
                       x + leg_width, y - size//2 + head_radius*2 + body_height + leg_height], 
                      fill=(0, 0, 0), outline=(0, 0, 0))
    
    def _draw_tree(self, draw, x, y, size):
        """Draw a simple tree shape"""
        # Trunk (rectangle)
        trunk_width = size // 6
        trunk_height = size // 2
        draw.rectangle([x - trunk_width//2, y - size//2 + size//4, 
                       x + trunk_width//2, y - size//2 + size//4 + trunk_height], 
                      fill=(139, 69, 19), outline=(0, 0, 0))  # Brown trunk
        
        # Leaves (circle)
        leaves_radius = size // 2
        draw.ellipse([x - leaves_radius, y - size//2, x + leaves_radius, y - size//2 + leaves_radius], 
                    fill=(0, 128, 0), outline=(0, 0, 0))  # Green leaves

class APITester:
    """Test generated images with the AI Object Counter API"""
    
    def __init__(self, api_url: str = "http://localhost:8000"):
        self.api_url = api_url
        self.session = requests.Session()
    
    def test_image(self, image_path: str, object_type: str) -> Dict[str, Any]:
        """Test a single image with the API"""
        try:
            with open(image_path, 'rb') as f:
                files = {'file': f}
                data = {'object_type': object_type}
                
                response = self.session.post(
                    f"{self.api_url}/api/count",
                    files=files,
                    data=data
                )
                
                if response.status_code == 200:
                    result = response.json()
                    return {
                        'success': True,
                        'predicted_count': result['count'],
                        'confidence': result['confidence'],
                        'processing_time': result['processing_time']
                    }
                else:
                    return {
                        'success': False,
                        'error': f"HTTP {response.status_code}: {response.text}"
                    }
                    
        except Exception as e:
            return {
                'success': False,
                'error': str(e)
            }
    
    def test_images(self, image_paths: List[str], object_type: str) -> List[Dict[str, Any]]:
        """Test multiple images with the API"""
        results = []
        
        for i, image_path in enumerate(image_paths):
            print(f"🧪 Testing image {i+1}/{len(image_paths)}: {os.path.basename(image_path)}")
            result = self.test_image(image_path, object_type)
            results.append(result)
            
            if result['success']:
                print(f"   ✅ Count: {result['predicted_count']}, Confidence: {result['confidence']:.2f}")
            else:
                print(f"   ❌ Error: {result['error']}")
        
        return results
    
    def generate_performance_report(self, results: List[Dict[str, Any]], object_type: str) -> Dict[str, Any]:
        """Generate a performance report from test results"""
        successful_results = [r for r in results if r['success']]
        
        if not successful_results:
            return {
                'object_type': object_type,
                'total_tests': len(results),
                'successful_tests': 0,
                'success_rate': 0.0,
                'error': 'No successful tests'
            }
        
        confidences = [r['confidence'] for r in successful_results]
        processing_times = [r['processing_time'] for r in successful_results]
        
        return {
            'object_type': object_type,
            'total_tests': len(results),
            'successful_tests': len(successful_results),
            'success_rate': len(successful_results) / len(results),
            'avg_confidence': sum(confidences) / len(confidences),
            'min_confidence': min(confidences),
            'max_confidence': max(confidences),
            'avg_processing_time': sum(processing_times) / len(processing_times),
            'min_processing_time': min(processing_times),
            'max_processing_time': max(processing_times)
        }

def main():
    """Main function for command-line usage"""
    parser = argparse.ArgumentParser(description='Generate test images for AI Object Counter')
    parser.add_argument('--object-type', required=True, help='Type of object to generate')
    parser.add_argument('--count', type=int, default=5, help='Number of images to generate')
    parser.add_argument('--blur', type=float, default=0.0, help='Blur level (0.0-1.0)')
    parser.add_argument('--rotation', type=float, nargs=2, default=[0, 0], help='Rotation range in degrees')
    parser.add_argument('--noise', type=float, default=0.0, help='Noise level (0.0-1.0)')
    parser.add_argument('--test-api', action='store_true', help='Test generated images with API')
    parser.add_argument('--output-dir', default='backend/data/generated_images', help='Output directory for images')
    
    args = parser.parse_args()
    
    # Generate images
    generator = AIImageGenerator()
    images = generator.generate_test_images(
        object_type=args.object_type,
        count=args.count,
        blur_level=args.blur,
        rotation_range=tuple(args.rotation),
        noise_level=args.noise
    )
    
    # Save images
    file_paths = generator.save_images(images, args.output_dir)
    
    print(f"\n✅ Generated {len(file_paths)} images for '{args.object_type}'")
    
    # Test with API if requested
    if args.test_api:
        print(f"\n🧪 Testing images with API...")
        tester = APITester()
        results = tester.test_images(file_paths, args.object_type)
        
        # Generate report
        report = tester.generate_performance_report(results, args.object_type)
        print(f"\n📊 Performance Report:")
        print(f"   Object Type: {report['object_type']}")
        print(f"   Success Rate: {report['success_rate']:.1%}")
        print(f"   Avg Confidence: {report['avg_confidence']:.2f}")
        print(f"   Avg Processing Time: {report['avg_processing_time']:.3f}s")

if __name__ == "__main__":
    main()
