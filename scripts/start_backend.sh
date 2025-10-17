#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="$ROOT_DIR/backend"
VENV_DIR="$ROOT_DIR/venv"
HOST_IP=${HOST_IP:-127.0.0.1}

echo "🚀 Starting AI Object Counter Backend..."

if pgrep -f "uvicorn" >/dev/null; then
    echo "🔄 Stopping existing uvicorn instances..."
    pkill -f "uvicorn" || true
fi

if [ ! -d "$VENV_DIR" ]; then
    echo "📦 Creating virtual environment at $VENV_DIR"
    python3 -m venv "$VENV_DIR"
fi

echo "🔧 Activating virtual environment..."
source "$VENV_DIR/bin/activate"

echo "📥 Installing backend dependencies..."
pip install --quiet -r "$BACKEND_DIR/requirements.txt"

export PYTHONPATH="$BACKEND_DIR:${PYTHONPATH:-}"

echo "📁 Ensuring data directories exist..."
python - <<'PY'
from app.core.config import settings

settings.ensure_directories()
print("✔ Data directories ready under", settings.data_dir)
PY

echo "🌟 Launching FastAPI with Uvicorn..."
echo "📍 API:           http://${HOST_IP}:8000"
echo "📚 Docs:         http://${HOST_IP}:8000/docs"
echo "🔍 Health Check: http://${HOST_IP}:8000/health"
echo "📊 Metrics:      http://${HOST_IP}:8000/metrics"

cd "$BACKEND_DIR"
uvicorn app.main:app --host 0.0.0.0 --port 8000
