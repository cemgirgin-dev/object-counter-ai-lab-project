#!/usr/bin/env python3
"""
Generate test metrics for the AI Object Counter dashboard
"""
import requests
import time
import random

def generate_test_data():
    """Generate test API calls to create metrics"""
    base_url = "http://localhost:8000"
    
    print("🧪 Generating test metrics for Grafana dashboard...")
    
    # Test different endpoints to generate metrics
    endpoints = [
        "/health",
        "/object-types", 
        "/api/learned-objects",
        "/metrics"
    ]
    
    for i in range(10):
        print(f"📊 Generating test data batch {i+1}/10...")
        
        # Call various endpoints
        for endpoint in endpoints:
            try:
                response = requests.get(f"{base_url}{endpoint}", timeout=5)
                if response.status_code == 200:
                    print(f"  ✅ {endpoint}")
                else:
                    print(f"  ⚠️  {endpoint} - {response.status_code}")
            except Exception as e:
                print(f"  ❌ {endpoint} - {e}")
        
        # Wait between batches
        time.sleep(2)
    
    print("✅ Test data generation complete!")
    print("📊 Check your Grafana dashboard at http://localhost:3001")
    print("🔍 You should now see metrics in the 'AI Object Counter Dashboard'")

if __name__ == "__main__":
    generate_test_data()
