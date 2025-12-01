# Makefile for E-commerce Microservice Project

.PHONY: help build test clean deploy local-up local-down

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build Docker image
	docker build -t ecommerce-api ./api

test: ## Run tests
	cd api && python -m pytest -v

test-cov: ## Run tests with coverage
	cd api && python -m pytest --cov=. --cov-report=html

clean: ## Clean up Docker containers and images
	docker-compose down -v
	docker system prune -f
	docker image rm ecommerce-api || true

local-up: ## Start local development environment
	docker-compose up -d

local-down: ## Stop local development environment
	docker-compose down

local-logs: ## View logs from local services
	docker-compose logs -f

terraform-init: ## Initialize Terraform
	cd infrastructure && terraform init

terraform-plan: ## Show Terraform plan
	cd infrastructure && terraform plan

terraform-apply: ## Apply Terraform changes
	cd infrastructure && terraform apply

k8s-deploy: ## Deploy to Kubernetes
	kubectl apply -f kubernetes/ecommerce-api/templates/

helm-deploy: ## Deploy using Helm
	helm upgrade --install ecommerce-api ./kubernetes/ecommerce-api --namespace ecommerce --create-namespace

monitoring-deploy: ## Deploy monitoring stack
	kubectl apply -f monitoring/

k8s-status: ## Check Kubernetes deployment status
	kubectl get pods,svc,ingress -n ecommerce
	kubectl get pods,svc,ingress -n monitoring

api-test: ## Test API endpoints
	curl http://localhost:8000/health
	curl http://localhost:8000/products

format: ## Format Python code
	cd api && black . && isort .

lint: ## Lint Python code
	cd api && flake8 . && mypy .