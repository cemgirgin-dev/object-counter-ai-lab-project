# 🚀 AI Object Counter - Startup Guide

This guide explains how to start the AI Object Counter system using the provided startup scripts.

## 📋 Prerequisites

Before running the system, ensure you have:

- **Python 3.8+** installed
- **Flutter** installed and configured for web development
- **Docker** installed and running
- **Git** (for cloning the repository)

## 🎯 Quick Start Options

### Option 1: Start Everything at Once
```bash
./start_system.sh
```
This will start all components (backend, frontend, and monitoring) in the correct order.

### Option 2: Start Components Individually

#### Backend Only
```bash
./start_backend.sh
```
- Starts the FastAPI backend with YOLOv8
- Available at: http://localhost:8000
- API docs: http://localhost:8000/docs

#### Frontend Only
```bash
./start_frontend.sh
```
- Starts the Flutter web application
- Available at: http://localhost:3000
- Features: Basic Mode, Advanced Mode, Generator, Monitor

#### Monitoring Only
```bash
./start_monitoring.sh
```
- Starts Prometheus and Grafana
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3001 (admin/admin)

## 🔧 What Each Script Does

### `start_backend.sh`
- ✅ Stops any existing backend processes
- ✅ Creates/activates Python virtual environment
- ✅ Installs/updates dependencies
- ✅ Creates necessary directories
- ✅ Starts FastAPI server with YOLOv8 model

### `start_frontend.sh`
- ✅ Stops any existing Flutter processes
- ✅ Checks Flutter installation
- ✅ Gets Flutter dependencies
- ✅ Enables web support
- ✅ Cleans previous builds
- ✅ Starts Flutter web server

### `start_monitoring.sh`
- ✅ Stops existing Docker containers
- ✅ Checks Docker installation
- ✅ Creates monitoring directories
- ✅ Starts Prometheus and Grafana
- ✅ Verifies services are running

### `start_system.sh`
- ✅ Checks all prerequisites
- ✅ Starts backend, frontend, and monitoring
- ✅ Provides comprehensive status information
- ✅ Handles cleanup on exit (Ctrl+C)

## 🌐 Access Points

Once all services are running:

| Service | URL | Description |
|---------|-----|-------------|
| **Frontend** | http://localhost:3000 | Main web application |
| **Backend API** | http://localhost:8000 | REST API endpoints |
| **API Docs** | http://localhost:8000/docs | Interactive API documentation |
| **Health Check** | http://localhost:8000/health | Backend health status |
| **Metrics** | http://localhost:8000/metrics | Prometheus metrics |
| **Prometheus** | http://localhost:9090 | Metrics collection |
| **Grafana** | http://localhost:3001 | Metrics visualization |

## 🎯 Features Available

### Basic Mode
- Object counting with YOLOv8
- Drag & drop image upload
- Real-time processing with animations
- Safety mechanism for military content

### Advanced Mode
- Few-shot learning for custom objects
- Training image upload
- Model testing and validation

### Generator
- AI-powered image generation
- Configurable parameters
- Batch image creation

### Monitor
- Real-time metrics visualization
- Performance monitoring
- System health tracking

## 🛑 Stopping Services

### Stop All Services
```bash
# If using start_system.sh, press Ctrl+C
# Or manually stop all:
pkill -f "python.*main.py"
pkill -f "flutter.*web"
docker-compose down
```

### Stop Individual Services
```bash
# Backend only
pkill -f "python.*main.py"

# Frontend only
pkill -f "flutter.*web"

# Monitoring only
docker-compose down
```

## 🔍 Troubleshooting

### Port Already in Use
The scripts automatically handle port conflicts by stopping existing processes.

### Docker Not Running
```bash
# Start Docker Desktop or Docker daemon
# Then retry:
./start_monitoring.sh
```

### Flutter Not Found
```bash
# Install Flutter: https://flutter.dev/docs/get-started/install
# Then retry:
./start_frontend.sh
```

### Python Dependencies Issues
```bash
# Recreate virtual environment:
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## 📊 Monitoring Dashboard

After starting the monitoring stack:

1. Open Grafana: http://localhost:3001
2. Login with: `admin` / `admin`
3. Navigate to "AI Object Counter Dashboard"
4. View real-time metrics and performance data

## 🎉 Success Indicators

You'll know everything is working when you see:

- ✅ Backend: "FastAPI server running on http://localhost:8000"
- ✅ Frontend: "Flutter web server running on http://localhost:3000"
- ✅ Monitoring: "Prometheus and Grafana started successfully"

## 📝 Logs

- Backend logs: Check terminal output or `backend.log`
- Frontend logs: Check terminal output or `frontend.log`
- Monitoring logs: `docker-compose logs -f`

---

**Happy coding! 🚀**
