# Object Recognition Platform

Modernised version of the Group-6 object counting project rebuilt with a modular FastAPI backend, Flutter web frontend, and production-style tooling. The backend combines YOLOv8 inference, a defensive safety pipeline, few-shot learning, and a Prometheus/Grafana monitoring stack; the frontend delivers a Material Design 3 interface for interactive workflows.

## 🔍 Highlights
- **Secure object counting:** YOLOv8 detection pipeline that stores results in SQLite and exposes FastAPI endpoints.
- **Safety guardrails:** `safety_pipeline` blocks military-vehicle content using filename, text, and image analysis.
- **Few-shot learning:** Upload a handful of samples to teach new object categories on the fly.
- **Synthetic image generation:** `tools/image_generator.py` creates test sets with augmentations.
- **Monitoring ready:** Prometheus metrics + Grafana dashboards for runtime observability.
- **Clean architecture:** Service layers live under `app/services`, configuration under `app/core`, routers under `app/api`.

## 📁 Repository Layout
```
backend/
  app/
    api/             # FastAPI routers (counting, few-shot, metrics, etc.)
    core/            # Central configuration and constants
    services/        # YOLO, safety, database, metrics, few-shot utilities
    dependencies.py  # FastAPI dependency providers
    main.py          # Uvicorn entrypoint
  data/              # Uploaded files, model weights, generated images (auto-created)
  tests/             # Pytest suites targeting the backend
frontend/            # Flutter web client
infrastructure/      # Docker Compose files, monitoring configs
scripts/             # Startup and helper scripts
tools/               # Supporting utilities (image generator, metrics scripts)
docs/                # Legacy documentation and reports
archive/             # Previous frontend variants kept for reference
```

## ⚙️ Setup & Execution

### 1. Prerequisites
- Python 3.10 or newer (`python3` on macOS)
- Flutter 3.x with web support (`flutter config --enable-web`)
- Docker & Docker Compose (required for monitoring stack)
- macOS Apple Silicon: ensure Xcode command line tools and Homebrew are up to date.

### 2. Prepare the repository
```bash
git clone <repo-url>.git
cd object_recognition
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r backend/requirements.txt
```

### 3. Install Flutter dependencies
```bash
cd frontend
flutter pub get
cd ..
```

### 4. Run the system
#### Automatic (backend + frontend + monitoring)
```bash
./scripts/start_system.sh
```
> The very first run may time out while dependencies download; if the backend stops early, start the services individually as shown below.

#### Manual launch
```bash
# Terminal 1 – Backend (FastAPI)
./scripts/start_backend.sh

# Terminal 2 – Frontend (Flutter Web)
./scripts/start_frontend.sh

# Terminal 3 – Monitoring (Prometheus & Grafana, optional)
./scripts/start_monitoring.sh
```

### 5. Access points
- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- Swagger docs: http://localhost:8000/docs
- Safety statistics: http://localhost:8000/api/safety-stats
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3001 (default creds `admin/admin`)

## ✅ Testing & Validation
- Backend tests:
  ```bash
  cd backend
  pytest -q
  ```
- Health check: `curl http://localhost:8000/health`
- Safety check: send a military-themed image to `/api/count`; it should return HTTP 403.

## 🧯 Troubleshooting
- **Port collisions (3000 / 8000)**  
  ```bash
  lsof -ti :8000 :3000 | xargs kill -9
  ```
  Then rerun the desired script.

- **Flutter `file_picker` warnings**  
  Known upstream behaviour; web builds still run correctly.

- **Large model weights**  
  Files in `backend/data/weights/*.pt` may exceed GitHub’s 100 MB limit. Consider Git LFS or hosting weights outside the repository before pushing.

## 📦 Runtime Data Locations
- Uploads: `backend/data/uploads/`
- Segmented visuals: `backend/data/segmented_images/`
- Few-shot artefacts: `backend/data/few_shot/`
- SQLite DB: `backend/data/db/object_counter.db`

These paths are excluded via `.gitignore`; remove or clean them before committing if unnecessary.


## 🗺️ Next Steps
- Explore `/docs` in the backend and the Flutter UI to confirm end-to-end flows.
- Tailor the Grafana dashboards once the monitoring stack is up.
- Use the few-shot endpoints to fine-tune for your own object categories.
- Browse `docs/legacy/` for historical reports and reference material.

With this structure you have a clean, documented base that is ready for publication on your personal GitHub or further feature development. Remember to review large assets before committing to keep the repository lightweight.
