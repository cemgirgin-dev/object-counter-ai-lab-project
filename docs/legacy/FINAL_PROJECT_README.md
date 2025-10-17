# 🚀 AI Engineering Lab - Complete Project (Final Presentation)

## 🎯 Project Overview

This is the **COMPLETE** AI Engineering Lab project featuring:
- **Week 1**: Core object counting with YOLOv8
- **Week 2**: Advanced monitoring, image generation, and few-shot learning
- **Week 3**: AI Safety mechanism with military vehicle detection

## ✨ Key Features

### 🛡️ AI Safety System (Week 3)
- **Military Vehicle Detection**: Prevents counting of military vehicles
- **Multi-layered Protection**: Object type + image content + filename analysis
- **Real-time Monitoring**: Safety metrics and block statistics
- **Beautiful Error Handling**: User-friendly safety messages

### 🎨 Modern Flutter Web UI
- **Material Design 3**: Latest design system
- **Responsive Design**: Works on desktop and mobile
- **Smooth Animations**: Professional user experience
- **Drag & Drop**: Easy image upload functionality

### 🧠 Advanced ML Pipeline
- **YOLOv8 Object Detection**: High accuracy object counting
- **Few-Shot Learning**: Learn new object types dynamically
- **Image Generation**: Automated test image creation
- **Performance Optimization**: Optimized for M1 MacBook Air

### 📊 Comprehensive Monitoring
- **Prometheus Metrics**: Real-time performance tracking
- **Grafana Dashboards**: Beautiful data visualization
- **Safety Statistics**: Monitor safety system performance
- **API Documentation**: Complete Swagger documentation

## 🚀 Quick Start (For Your Friends)

### Prerequisites
- Python 3.8+
- Flutter 3.0+
- Docker & Docker Compose

### 1. Clone and Setup
```bash
git clone <your-repo-url>.git
cd object_recognition
```

### 2. Python Environment
```bash
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r backend/requirements.txt
```

### 3. Flutter Setup
```bash
cd frontend
flutter pub get
cd ..
```

### 4. Start Everything (Easiest Way)
```bash
./scripts/start_system.sh
```

**OR** Start individually:
```bash
# Terminal 1: Backend
./scripts/start_backend.sh

# Terminal 2: Frontend  
./scripts/start_frontend.sh

# Terminal 3: Monitoring (Optional)
./scripts/start_monitoring.sh
```

## 🌐 Access Points

| Service | URL | Description |
|---------|-----|-------------|
| **🎨 Frontend** | http://localhost:3000 | Main Flutter web application |
| **🔧 Backend API** | http://localhost:8000 | FastAPI with safety system |
| **📚 API Docs** | http://localhost:8000/docs | Swagger documentation |
| **🛡️ Safety Stats** | http://localhost:8000/api/safety-stats | Safety system statistics |
| **📊 Prometheus** | http://localhost:9090 | Metrics collection |
| **📈 Grafana** | http://localhost:3001 | Monitoring dashboard (admin/admin) |

## 🎯 How to Use

### Basic Object Counting
1. Go to http://localhost:3000
2. Upload an image
3. Select object type (car, cat, dog, person, tree, building, sky, ground, hardware)
4. Click "Count Objects"
5. View results with confidence scores

### Advanced Features
- **Generator Tab**: Create test images with various augmentations
- **Advanced Mode**: Learn new object types with few-shot learning
- **Monitor Tab**: View real-time metrics and safety statistics

### Safety System Testing
1. Upload a military image (tank, etc.)
2. Select any object type
3. See the safety system block the request with a beautiful error message
4. Check safety statistics at `/api/safety-stats`

## 🛡️ Safety System Features

The AI Safety system prevents misuse by:
- **Detecting Military Vehicles**: Blocks images containing military content
- **Text Analysis**: Prevents military-related object types
- **Filename Analysis**: Checks for military keywords in filenames
- **Multi-layered Protection**: Multiple safety checks for robust protection

## 📊 Monitoring & Metrics

### Grafana Dashboard
- Real-time request metrics
- Model performance tracking
- Safety system statistics
- System resource usage

### Available Metrics
- `http_requests_total` - Total HTTP requests
- `model_inference_duration_seconds` - Model processing time
- `safety_blocks_total` - Safety system blocks
- `object_detection_count` - Objects detected per type

## 🧪 Testing the System

### Test Safety System
```bash
# Test military object type blocking
curl -X POST "http://localhost:8000/api/count" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@test_image.jpg" \
  -F "object_type=tank"

# Should return 403 Forbidden with safety message
```

### Test Normal Operation
```bash
# Test normal object counting
curl -X POST "http://localhost:8000/api/count" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@cat_image.jpg" \
  -F "object_type=cat"

# Should return 200 OK with count results
```

## 🔧 Configuration

### Environment Variables
- `BACKEND_PORT`: Backend server port (default: 8000)
- `FRONTEND_PORT`: Frontend server port (default: 3000)
- `GRAFANA_PORT`: Grafana port (default: 3001)
- `PROMETHEUS_PORT`: Prometheus port (default: 9090)

### Model Configuration
- **YOLOv8 Model**: Uses YOLOv8m for optimal accuracy/speed balance
- **Device**: Auto-detects M1 Mac (MPS) or falls back to CPU
- **Confidence Threshold**: 0.25 for optimal detection

## 🛑 Stopping the System

```bash
# Stop all services
pkill -f 'uvicorn'
pkill -f 'flutter.*web'
docker compose -f infrastructure/docker-compose.yaml down
```

## 📁 Project Structure

```
ai_engineering_lab/
├── backend/                 # FastAPI backend
│   ├── main.py             # Main API server with safety system
│   ├── safety_pipeline.py  # Military vehicle detection
│   ├── yolo_ml_pipeline.py # YOLOv8 ML pipeline
│   ├── few_shot_learning.py # Few-shot learning
│   ├── metrics.py          # Prometheus metrics
│   └── database.py         # SQLite database
├── frontend/               # Flutter web application
│   ├── lib/
│   │   ├── main.dart       # Main Flutter app
│   │   └── advanced_mode_screen.dart # Advanced features
│   └── pubspec.yaml        # Flutter dependencies
├── monitoring/             # Monitoring configuration
│   ├── prometheus.yml      # Prometheus config
│   └── grafana/            # Grafana dashboards
├── scripts/                # Training and utility scripts
├── .gitlab-ci.yml          # A100 GPU training pipeline
├── MODEL_CARD.md           # Model documentation
└── requirements.txt        # Python dependencies
```

## 🎉 What's Included

### ✅ Week 1 Features
- Object detection with YOLOv8
- REST API with FastAPI
- Flutter web UI
- SQLite database
- Comprehensive testing

### ✅ Week 2 Features
- Prometheus metrics and Grafana dashboards
- Automated image generation
- Few-shot learning for new object types
- Performance monitoring

### ✅ Week 3 Features
- AI Safety mechanism
- Military vehicle detection
- GitLab CI for A100 GPU training
- Complete model documentation
- Production-ready safety system

## 🚀 A100 GPU Training

The project includes a complete GitLab CI pipeline for A100 GPU training:
- Automated model training on A100 GPU
- Model testing and validation
- Model card generation
- Artifact deployment

## 🤝 For Your Friends

This branch contains the **COMPLETE** project ready for:
- **Demo/Presentation**: All features working
- **Development**: Full codebase with documentation
- **Learning**: Complete AI Engineering Lab implementation
- **Extension**: Easy to add new features

## 📞 Support

If you encounter any issues:
1. Check the logs in the terminal
2. Verify all services are running
3. Check the API documentation at http://localhost:8000/docs
4. Review the safety statistics at http://localhost:8000/api/safety-stats

## 🎯 Success Criteria

Your friends should be able to:
- ✅ Start the system with one command
- ✅ Upload images and count objects
- ✅ See the safety system block military content
- ✅ View beautiful monitoring dashboards
- ✅ Test all advanced features
- ✅ Understand the complete AI Engineering workflow

---

**🎉 Enjoy exploring the complete AI Engineering Lab project!** 🚀
