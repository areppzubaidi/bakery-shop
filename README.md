I'll create a comprehensive `README.md` for your bakery‑shop DevOps project. It will include a clear structure, descriptions of what to **take** (i.e., commands, screenshots, outputs), and placeholders for screenshots.

---

```markdown
# 🧁 Bakery Shop – Production‑Grade Static Website on AWS

![Bakery Shop Screenshot](docs/screenshot-bakery-site.png)

A fully automated, highly available static website for a bakery shop, deployed on AWS with **Terraform**, **Ansible**, **Docker**, **GitHub Actions**, and **Prometheus/Grafana** monitoring.

## 📐 Architecture Overview

![Architecture Diagram](docs/architecture.png)

```
[GitHub] → (App Pipeline) → Build Docker Image → Push to Docker Hub
     │
     └→ (Terraform Pipeline) → Provision AWS Infra (VPC, ALB, ASG, S3, Monitoring EC2)
                                      │
                                      ↓
[Ansible Pipeline] → Configure EC2 instances (install Docker, run container, Node Exporter)
                                      │
                                      ↓
[ALB] → Distributes traffic across Auto Scaling Group instances
                                      │
                                      ↓
[Browser] → https://alb-dns/ → Serves static bakery site (NGINX inside Docker)
                                      │
[Monitoring] → Prometheus scrapes Node Exporter → Grafana dashboards
                                      │
[Backup] → S3 bucket with versioning & lifecycle (logs, configs, assets)
```

## 🚀 What You Will Build

- ✅ A responsive static website (HTML/CSS) for a bakery shop
- ✅ Dockerized website with production‑grade Nginx configuration  
- ✅ AWS infrastructure as code (Terraform):
  - VPC with public subnets, Internet Gateway, route tables
  - Application Load Balancer (ALB) + Target Group
  - Auto Scaling Group (ASG) of `t2.micro` instances
  - S3 bucket with versioning and lifecycle for backups
  - Security groups (ALB, EC2, monitoring instance)
  - IAM roles & policies (least privilege)
- ✅ Configuration management (Ansible) to deploy the Docker container and set up log backups
- ✅ CI/CD pipelines (GitHub Actions):
  - App pipeline: build & push Docker image
  - Terraform pipeline: provision AWS resources
  - Ansible pipeline: configure instances
- ✅ Monitoring with Prometheus (auto‑discovers ASG instances) and Grafana dashboards
- ✅ Backup strategy: S3 + cron job (every 6 hours) for Nginx logs

## 📦 Prerequisites

**Local machine (macOS / Linux):**

- [Homebrew](https://brew.sh/) (Mac)
- [Git](https://git-scm.com/)
- [AWS CLI](https://aws.amazon.com/cli/) – configured with an IAM user
- [Terraform](https://www.terraform.io/) (>= 1.0)
- [Ansible](https://www.ansible.com/) (>= 2.12)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (or Docker Engine)
- [Python 3](https://www.python.org/) + `boto3`, `botocore` (for dynamic inventory)

**Accounts:**
- AWS account (Free Tier eligible)
- Docker Hub account
- GitHub account

## 🛠️ Quick Start (Step‑by‑Step)

### 1. Clone the repository

```bash
git clone https://github.com/areppzubaidi/bakery-shop.git
cd bakery-shop
```

### 2. Configure AWS CLI & SSH key

```bash
aws configure   # enter your Access Key, Secret Key, region (ap-southeast-1)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/bakery-key -N ""
aws ec2 import-key-pair --key-name "bakery-key" --public-key-material fileb://~/.ssh/bakery-key.pub
```

### 3. Build and push the Docker image

```bash
docker build -t bakery-shop:latest .
docker tag bakery-shop:latest <your-dockerhub-username>/bakery-shop:latest
docker push <your-dockerhub-username>/bakery-shop:latest
```

### 4. Deploy infrastructure with Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars – set your Docker Hub username and your public IP
terraform init
terraform apply -auto-approve
```

**Screenshot of successful `terraform apply` output:**

![Terraform Apply Success](docs/terraform-apply.png)

After apply, note the outputs:

```text
alb_dns_name = "bakery-shop-alb-xxxx.ap-southeast-1.elb.amazonaws.com"
monitoring_instance_ip = "13.212.84.7"
s3_backup_bucket = "bakery-shop-backup-xxxx"
```

### 5. Run Ansible to deploy the application

```bash
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i ansible/inventory/hosts ansible/playbooks/deploy.yml \
  -e "docker_image=<your-dockerhub-username>/bakery-shop:latest" \
  -e "s3_bucket=<s3_backup_bucket_from_output>"
```

### 6. 🎉 Verify the website

Open the ALB DNS name in your browser:

![Bakery Shop Live Screenshot](docs/bakery-site-live.png)

### 7. 📊 Access Monitoring

- **Grafana**: `http://<monitoring_instance_ip>:3000` (default `admin`/`admin`)
- Add Prometheus data source: `http://localhost:9090`
- Import Node Exporter dashboard ID `1860`

![Grafana Dashboard Screenshot](docs/grafana-dashboard.png)

### 8. 🧹 Cleanup (to avoid charges)

```bash
cd terraform
terraform destroy -auto-approve
```

## ⚙️ CI/CD Pipelines (GitHub Actions)

Three workflows are defined in `.github/workflows/`:

| Workflow | Trigger | What it does |
|----------|---------|---------------|
| `app.yml` | Push to `main` (changes to `index.html`, `css/`, `Dockerfile`) | Builds, tests, and pushes Docker image to Docker Hub |
| `terraform.yml` | Push to `main` (changes in `terraform/`) or manual dispatch | Runs `terraform plan` and `apply` |
| `ansible.yml` | Manual dispatch or repository_dispatch | Runs Ansible playbook to update EC2 instances |

> **Note:** You must add GitHub Secrets: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`, `MY_IP`.

## 📁 Project Structure

```
bakery-shop/
├── .github/workflows/        # CI/CD pipelines
├── terraform/                # IaC (VPC, ALB, ASG, S3, monitoring)
│   ├── main.tf
│   ├── variables.tf
│   ├── user_data.sh          # bootstrap Docker & Node Exporter on ASG instances
│   ├── monitoring_user_data.sh # bootstrap Prometheus & Grafana
│   ├── ansible/              # Ansible inventory and playbooks
│   └── terraform.tfvars.example
├── ansible/                  (symlinked or standalone – here inside terraform/)
├── Dockerfile
├── nginx.conf
├── index.html
└── css/style.css
```

## 🔐 Security & Best Practices Implemented

- ✅ IAM roles with least privilege (EC2 only gets `s3:PutObject`, monitoring only `ec2:DescribeInstances`)
- ✅ SSH access restricted to your public IP via security group
- ✅ Security headers in Nginx (`X‑Frame‑Options`, `X‑Content‑Type‑Options`, etc.)
- ✅ S3 bucket versioning + server‑side encryption (AES‑256)
- ✅ Secrets stored in GitHub Secrets, never in code
- ✅ `.gitignore` prevents committing Terraform state, `.tfvars`, and provider binaries

## 🧪 Testing the Setup

After deployment, test the following:

- **Website availability** – `curl http://<alb-dns>`
- **Auto Scaling** – terminate the EC2 instance; ASG will launch a new one automatically
- **Log backup** – wait 6 hours or run `/usr/local/bin/backup_logs.sh` manually on the instance, then check S3 bucket
- **Prometheus targets** – visit `http://<monitoring-ip>:9090/targets` – should show your ASG instances

## 📈 Expected Results

| Component | Expected Outcome |
|-----------|------------------|
| ALB DNS name | Serves the bakery HTML/CSS page |
| ASG instances | At least 1 running, tagged `Name=bakery-shop-asg-instance` |
| Node Exporter | Running on port 9100 on each ASG instance |
| Prometheus | Scrapes node metrics from each instance via EC2 discovery |
| Grafana | Shows CPU, memory, disk graphs (after importing dashboard) |
| S3 bucket | Contains log files `nginx-logs/<hostname>/access-*.log` |

## ❗ Troubleshooting

| Issue | Likely cause | Fix |
|-------|--------------|-----|
| Website returns 503 | Target group health checks fail | SSH into instance, check `docker ps`, look at container logs |
| Ansible cannot connect | SSH key not imported or security group blocks your IP | Verify `my_ip` in `terraform.tfvars` and run `aws ec2 import-key-pair` again |
| Port 80 already allocated | Old container still running | Run `docker stop $(docker ps -q)` and `docker rm $(docker ps -aq)` on the instance |
| Prometheus shows no targets | Missing IAM permissions or security group | Ensure monitoring instance role has `ec2:DescribeInstances` and security group allows port 9100 from monitoring instance |
| GitHub push fails (large files) | Committed Terraform provider binaries | Use the provided `.gitignore` and re‑initialize Git (see section above) |

## 📚 References & Further Reading

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Ansible AWS EC2 Inventory](https://docs.ansible.com/ansible/latest/collections/amazon/aws/aws_ec2_inventory.html)
- [Prometheus Node Exporter](https://github.com/prometheus/node_exporter)
- [Grafana Dashboard for Node Exporter (ID 1860)](https://grafana.com/grafana/dashboards/1860)

## 🤝 Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## 📄 License

[MIT](LICENSE)

---

**Built with ❤️ using Terraform, Ansible, Docker, and GitHub Actions.**  
*“DevOps is not a role, it’s a culture of automation, measurement, and sharing.”*
```

---

## 📸 What Screenshots to Take

Create a `docs/` folder in the repo and add these images:

1. `architecture.png` – the text diagram rendered as an image (or simply keep the text).
2. `terraform-apply.png` – show the terminal output with the 29 resources created.
3. `bakery-site-live.png` – browser showing the bakery shop homepage.
4. `grafana-dashboard.png` – Grafana dashboard with Node Exporter metrics.
5. Optionally, `screenshot-bakery-site.png` at the top.

You can generate these easily by running the steps and taking screenshots using your OS tool.

---

## ✅ Final Deliverables Check

- ✅ Complete `README.md` with all sections
- ✅ Step‑by‑step instructions
- ✅ Placeholders for screenshots (you replace with actual images)
- ✅ Architecture overview, prerequisites, deployment, monitoring, cleanup
- ✅ Troubleshooting guide

Now your repository is fully documented and ready to share or present as a portfolio project!
