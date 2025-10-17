#!/usr/bin/env bash
set -euo pipefail

# AI Object Counter - Complete System Startup Script

echo "🚀 Starting AI Object Counter Complete System..."
echo ""

# Determine host/IP configuration once and propagate to sub-scripts
HOST_IP=${HOST_IP:-127.0.0.1}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Function to check if a port is in use
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0  # Port is in use
    else
        return 1  # Port is free
    fi
}

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "🛑 Stopping all services..."
    pkill -f "uvicorn" 2>/dev/null || true
    pkill -f "flutter.*web" 2>/dev/null || true
    docker compose -f "$ROOT_DIR/infrastructure/docker-compose.yaml" down 2>/dev/null || true
    echo "✅ All services stopped"
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Check if required tools are installed
echo "🔍 Checking system requirements..."

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3 first."
    exit 1
fi

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    echo "📖 Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

echo "✅ All requirements satisfied!"
echo ""

# Start Backend
echo "🚀 Starting Backend..."
if check_port 8000; then
    echo "⚠️  Port 8000 is already in use. Stopping existing processes..."
    pkill -f "python.*main.py" 2>/dev/null || true
    sleep 2
fi

# Start backend in background
HOST_IP="$HOST_IP" "$SCRIPT_DIR/start_backend.sh" &
BACKEND_PID=$!

# Wait for backend to start
echo "⏳ Waiting for backend to start..."
sleep 10

# Check if backend is running
if ! check_port 8000; then
    echo "❌ Backend failed to start"
    cleanup
fi

echo "✅ Backend started successfully!"
echo ""

# Start Frontend
echo "🎨 Starting Frontend..."
if check_port 3000; then
    echo "⚠️  Port 3000 is already in use. Stopping existing processes..."
    pkill -f "flutter.*web" 2>/dev/null || true
    sleep 2
fi

# Start frontend in background
HOST_IP="$HOST_IP" "$SCRIPT_DIR/start_frontend.sh" &
FRONTEND_PID=$!

# Wait for frontend to start
echo "⏳ Waiting for frontend to start..."
sleep 15

# Check if frontend is running
if ! check_port 3000; then
    echo "❌ Frontend failed to start"
    cleanup
fi

echo "✅ Frontend started successfully!"
echo ""

# Start Monitoring
echo "📊 Starting Monitoring Stack..."
"$SCRIPT_DIR/start_monitoring.sh"

echo ""
echo "🎉 AI Object Counter System Started Successfully!"
echo ""
echo "📍 Services available at:"
echo "   • Frontend: http://${HOST_IP}:3000"
echo "   • Backend API: http://${HOST_IP}:8000"
echo "   • API Docs: http://${HOST_IP}:8000/docs"
echo "   • Prometheus: http://${HOST_IP}:9090"
echo "   • Grafana: http://${HOST_IP}:3001 (admin/admin)"
echo ""
echo "🎯 Features:"
echo "   • Basic Mode: Object counting with YOLOv8"
echo "   • Advanced Mode: Few-shot learning"
echo "   • Generator: AI image generation"
echo "   • Monitor: Prometheus & Grafana metrics"
echo "   • Safety: Military vehicle detection"
echo ""
echo "🛑 To stop all services: Press Ctrl+C"
echo ""

# Wait for user to stop
wait
