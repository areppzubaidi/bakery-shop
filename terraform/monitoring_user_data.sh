#!/bin/bash
set -e

apt-get update
apt-get install -y docker.io unzip
systemctl enable docker
systemctl start docker

# Install AWS CLI (needed for EC2 discovery)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install

# Create Prometheus config with EC2 service discovery
mkdir -p /etc/prometheus
cat > /etc/prometheus/prometheus.yml << 'PROM'
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'node_exporter'
    ec2_sd_configs:
      - region: ${aws_region}
        port: 9100
        filters:
          - name: tag:Name
            values: ['bakery-shop-asg-instance']
  - job_name: 'nginx'
    ec2_sd_configs:
      - region: ${aws_region}
        port: 9113
        filters:
          - name: tag:Name
            values: ['bakery-shop-asg-instance']
PROM

# Replace region placeholder
sed -i "s/\${aws_region}/$(curl -s http://169.254.169.254/latest/meta-data/placement/region)/g" /etc/prometheus/prometheus.yml

# Run Prometheus
docker run -d -p 9090:9090 -v /etc/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus

# Run Grafana (with persistent volume)
docker volume create grafana-storage
docker run -d -p 3000:3000 --name grafana -v grafana-storage:/var/lib/grafana grafana/grafana
