#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="$ROOT_DIR/infrastructure/docker-compose.yaml"
HOST_IP=${HOST_IP:-127.0.0.1}

echo "🚀 Starting AI Object Counter Monitoring Stack..."

if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

if [ ! -f "$COMPOSE_FILE" ]; then
    echo "❌ docker-compose.yaml not found at $COMPOSE_FILE"
    exit 1
fi

echo "🔄 Stopping any existing monitoring containers..."
docker compose -f "$COMPOSE_FILE" down >/dev/null 2>&1 || true

echo "📁 Preparing monitoring directories..."
mkdir -p "$ROOT_DIR/infrastructure/monitoring/grafana/provisioning/datasources"
mkdir -p "$ROOT_DIR/infrastructure/monitoring/grafana/provisioning/dashboards"
mkdir -p "$ROOT_DIR/infrastructure/monitoring/grafana/data"

echo "🐳 Starting Prometheus and Grafana via Docker Compose..."
docker compose -f "$COMPOSE_FILE" up -d

echo "⏳ Waiting for services to start..."
sleep 15

if docker compose -f "$COMPOSE_FILE" ps | grep -q "Up"; then
    cat <<MSG
✅ Monitoring stack started successfully!

📍 Services available at:
  • Prometheus: http://${HOST_IP}:9090
  • Grafana:   http://${HOST_IP}:3001 (admin/admin)
  • API Docs:  http://${HOST_IP}:8000/docs

🔧 Useful commands:
  • View logs: docker compose -f $COMPOSE_FILE logs -f
  • Stop:      docker compose -f $COMPOSE_FILE down
  • Restart:   docker compose -f $COMPOSE_FILE restart
MSG
else
    echo "❌ Failed to start monitoring stack"
    docker compose -f "$COMPOSE_FILE" logs
    exit 1
fi
