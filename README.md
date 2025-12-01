# Scalable E-commerce Microservice Deployment

This project demonstrates a complete DevOps pipeline for deploying a scalable e-commerce API microservice using modern cloud-native technologies.

## Architecture Overview

- **API Service**: FastAPI-based e-commerce REST API
- **Containerization**: Docker
- **Orchestration**: Kubernetes (EKS)
- **Infrastructure as Code**: Terraform
- **CI/CD**: GitHub Actions
- **Monitoring**: Prometheus + Grafana
- **Cloud Provider**: AWS (EKS, S3, CloudWatch)

## Project Structure

```
.
├── api/                          # E-commerce API service
│   ├── main.py                  # FastAPI application
│   ├── requirements.txt         # Python dependencies
│   ├── Dockerfile               # Container definition
│   └── tests.py                 # Unit tests
├── infrastructure/               # Terraform IaC
│   ├── main.tf                  # EKS cluster, VPC, S3
│   └── variables.tf             # Configuration variables
├── kubernetes/                   # Kubernetes manifests
│   └── ecommerce-api/           # Helm chart
├── monitoring/                   # Observability stack
│   ├── prometheus-config.yaml   # Prometheus configuration
│   ├── prometheus-deployment.yaml
│   ├── grafana-deployment.yaml
│   └── alert-rules.yaml         # Alerting rules
├── .github/workflows/           # GitHub Actions CI/CD
│   └── ci-cd.yml
├── docker-compose.yml           # Local development setup
└── README.md
```

## Prerequisites

- Docker & Docker Compose
- kubectl
- Helm
- Terraform
- AWS CLI configured
- GitHub repository with secrets configured

## Local Development

1. **Start services locally:**
   ```bash
   docker-compose up -d
   ```

2. **API will be available at:** `http://localhost:8000`
3. **Prometheus:** `http://localhost:9090`
4. **Grafana:** `http://localhost:3000` (admin/admin)

3. **Run tests:**
   ```bash
   cd api
   python -m pytest
   ```

## API Endpoints

- `GET /` - API information
- `GET /health` - Health check
- `GET /products` - List all products
- `GET /products/{id}` - Get specific product
- `POST /products` - Create new product
- `GET /orders` - List all orders
- `POST /orders` - Create new order
- `GET /users` - List all users

## Deployment

### 1. Infrastructure Setup

```bash
cd infrastructure
terraform init
terraform plan
terraform apply
```

### 2. Deploy Application

The CI/CD pipeline automatically:
- Runs tests
- Builds Docker image
- Pushes to GitHub Container Registry
- Deploys to Kubernetes via Helm
- Updates monitoring stack

### 3. Monitoring Setup

```bash
kubectl apply -f monitoring/
```

Access Grafana dashboards at: `http://grafana.local` (configure ingress)

## Auto-scaling

The deployment includes Horizontal Pod Autoscaler (HPA) configured for:
- CPU utilization: 80%
- Memory utilization: 80%
- Min replicas: 1
- Max replicas: 10

## Monitoring & Alerting

### Dashboards
- Application metrics (response time, error rates)
- Infrastructure metrics (CPU, memory, network)
- Kubernetes cluster metrics

### Alerts
- API service down
- High CPU/memory usage
- Pod count anomalies

## CI/CD Pipeline

The GitHub Actions workflow includes:

1. **Test Stage**: Unit tests with coverage
2. **Build Stage**: Docker image build and push
3. **Deploy Stage**: Kubernetes deployment via Helm
4. **Infrastructure Stage**: Terraform apply (on infra changes)
5. **Notify Stage**: Slack notifications

### Required GitHub Secrets

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `SLACK_WEBHOOK_URL`

## Scaling Considerations

- **Horizontal Scaling**: HPA based on CPU/memory
- **Database**: Add RDS PostgreSQL for production data
- **Caching**: Redis for session and API caching
- **Load Balancing**: AWS ALB Ingress Controller
- **Security**: AWS WAF, security groups, IAM roles

## Production Readiness

- [ ] Database migration scripts
- [ ] Secrets management (AWS Secrets Manager)
- [ ] Backup strategies
- [ ] Disaster recovery plan
- [ ] Security scanning (SonarQube, Snyk)
- [ ] Performance testing
- [ ] Blue/green deployment strategy

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Submit pull request

## License

MIT License