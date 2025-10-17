# Monitoring Setup

## Without Docker

(Instructions for Linux)

### Prometheus

1. Download Prometheus, either from the [official site](https://prometheus.io/download/) or using the command below:
   ```bash
   wget https://github.com/prometheus/prometheus/releases/download/v3.5.0/prometheus-3.5.0.linux-amd64.tar.gz
   ```
2. Extract the downloaded file:
   ```bash
   tar -xzf prometheus-3.5.0.linux-amd64.tar.gz
   ```
3. Move into the extracted directory:
   ```bash
   cd prometheus-3.5.0.linux-amd64
   ```
4. Start Prometheus with the following command:
   ```bash
   ./prometheus --config.file=../config/prometheus.yaml
   ```
5. Access the Prometheus web interface at http://localhost:9090.

### Grafana

1. Download Grafana, either from the [official site](https://grafana.com/grafana/download) or using the command below:
   ```bash
   wget https://dl.grafana.com/oss/release/grafana-12.1.0.linux-amd64.tar.gz
   ```
2. Extract the downloaded file:
   ```bash
   tar -xzf grafana-*.tar.gz
   ```
3. Move into the extracted directory:
   ```bash
   cd grafana-v12.1.0
   ```
4. Start Grafana with the following command:
   ```bash
   ./bin/grafana server web
   ```
5. Access the Grafana web interface at http://localhost:3000 (default username and password are both `admin`).

## With Docker

Make sure you have Docker installed and running.

1. Run the following command to start Prometheus and Grafana:
   ```bash
   docker-compose up -d
   ```
2. Access Prometheus at http://localhost:9090 and Grafana at http://localhost:3000 (default username and password are both `admin`).

# Example Application

This application simulates a dice roll and exposes metrics to Prometheus. It includes endpoints for rolling a single die and rolling 100 dice in a single request.

## Run the Application

1. Ensure you have Python and the required packages installed. You can install the necessary packages using:
   ```bash
   pip install -r requirements.txt
   ```
2. Start the application:
   ```bash
   flask run
   ```
3. Access the application at http://localhost:5000/rolldice to roll a single die or at http://localhost:5000/rolldice_100 to roll 100 dice in one request.

## Metrics

The application exposes metrics at the `/metrics` endpoint, which can be scraped by Prometheus. The metrics include:

## Monitoring Metrics

1. Open Grafana at http://localhost:3000.
2. Add a new data source:
   - Choose "Prometheus" as the data source type.
   - Set the URL to `http://localhost:9090` or `prometheus:9090`.
3. Create a new dashboard and add panels to visualize the metrics:
   - Use the metric `roll_count_total` to visualize the total number of dice rolls.
