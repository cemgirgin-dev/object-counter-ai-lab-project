#!/bin/bash

# AI Object Counter - Frontend Startup Script

echo "🎨 Starting AI Object Counter Frontend..."

# Kill any existing Flutter processes
echo "🔄 Stopping any existing Flutter processes..."
pkill -f "flutter.*web" 2>/dev/null || true
sleep 2

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    echo "📖 Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check if frontend directory exists
if [ ! -d "frontend" ]; then
    echo "❌ Frontend directory not found!"
    exit 1
fi

# Navigate to frontend directory
cd frontend

# Get Flutter dependencies
echo "📥 Getting Flutter dependencies..."
flutter pub get

# Check for Flutter web support
echo "🌐 Checking Flutter web support..."
flutter config --enable-web

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Determine host/IP configuration (allow override via HOST_IP env var)
HOST_IP=${HOST_IP:-127.0.0.1}

# Start the Flutter web server
echo "🌟 Starting Flutter web server on IP ${HOST_IP}..."
echo "📍 Web app will be available at: http://${HOST_IP}:3000"
echo "🎯 Features:"
echo "   • Basic Mode: Object counting with YOLOv8"
echo "   • Advanced Mode: Few-shot learning"
echo "   • Generator: AI image generation"
echo "   • Monitor: Prometheus & Grafana metrics"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

flutter run \
  -d web-server \
  --web-hostname "${HOST_IP}" \
  --web-port 3000 \
  --dart-define="BASE_HOST=${HOST_IP}"
