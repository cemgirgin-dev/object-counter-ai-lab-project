#!/bin/bash

# 🚀 AI Engineering Lab - Setup Script for Friends
# This script sets up the complete project for easy demo/presentation

echo "🎯 AI Engineering Lab - Complete Project Setup"
echo "=============================================="
echo ""

# Check if we're in the right directory
if [ ! -f "backend/requirements.txt" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

echo "✅ Found project files"
echo ""

# Check Python installation
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: Python 3 is not installed"
    echo "   Please install Python 3.8+ and try again"
    exit 1
fi

echo "✅ Python 3 found: $(python3 --version)"
echo ""

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter is not installed"
    echo "   Please install Flutter 3.0+ and try again"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"
echo ""

# Check Docker installation
if ! command -v docker &> /dev/null; then
    echo "⚠️  Warning: Docker is not installed"
    echo "   Monitoring features will not be available"
    echo "   You can still run the main application"
    echo ""
fi

# Create virtual environment
echo "🔧 Setting up Python virtual environment..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo "✅ Virtual environment created"
else
    echo "✅ Virtual environment already exists"
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

export PYTHONPATH="backend:${PYTHONPATH:-}"

# Install Python dependencies
echo "🔧 Installing backend dependencies..."
pip install -r backend/requirements.txt --quiet
echo "✅ Python dependencies installed"
echo ""

# Setup Flutter
echo "🔧 Setting up Flutter dependencies..."
pushd frontend >/dev/null
flutter pub get --quiet
popd >/dev/null
echo "✅ Flutter dependencies installed"
echo ""

# Make scripts executable
echo "🔧 Making scripts executable..."
chmod +x scripts/start_system.sh
chmod +x scripts/start_backend.sh
chmod +x scripts/start_frontend.sh
chmod +x scripts/start_monitoring.sh
echo "✅ Scripts are now executable"
echo ""

# Create necessary directories
echo "🔧 Creating necessary directories..."
python - <<'PY'
from app.core.config import settings

settings.ensure_directories()
print("✅ Backend data directories ready at", settings.data_dir)
PY
mkdir -p infrastructure/monitoring/grafana/data
echo "✅ Directories created"
echo ""

echo "🎉 Setup Complete!"
echo "=================="
echo ""
echo "🚀 To start the complete system:"
echo "   ./scripts/start_system.sh"
echo ""
echo "🌐 Access Points:"
echo "   Frontend:    http://localhost:3000"
echo "   Backend:     http://localhost:8000"
echo "   API Docs:    http://localhost:8000/docs"
echo "   Grafana:     http://localhost:3001 (admin/admin)"
echo ""
echo "📚 For detailed instructions, see:"
echo "   FINAL_PROJECT_README.md"
echo ""
echo "🎯 Your friends can now run the complete AI Engineering Lab project!"
echo ""
