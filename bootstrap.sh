#!/bin/bash

# Bootstrap script for E-commerce Microservice Deployment
# This script sets up the entire infrastructure and deploys the application

set -e

echo "🚀 Starting E-commerce Microservice Deployment Bootstrap"

# Check prerequisites
command -v terraform >/dev/null 2>&1 || { echo "❌ Terraform is required but not installed. Aborting."; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed. Aborting."; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "❌ Helm is required but not installed. Aborting."; exit 1; }
command -v aws >/dev/null 2>&1 || { echo "❌ AWS CLI is required but not installed. Aborting."; exit 1; }

echo "✅ Prerequisites check passed"

# Infrastructure setup
echo "🏗️  Setting up infrastructure with Terraform..."
cd infrastructure
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan

# Get EKS cluster info
CLUSTER_NAME=$(terraform output -raw cluster_name)
AWS_REGION=$(terraform output -raw region)

echo "🔗 Connecting to EKS cluster: $CLUSTER_NAME"
aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

# Wait for cluster to be ready
echo "⏳ Waiting for EKS cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=600s

# Install monitoring stack
echo "📊 Deploying monitoring stack..."
cd ../monitoring
kubectl apply -f .
kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n monitoring
kubectl wait --for=condition=available --timeout=300s deployment/grafana -n monitoring

# Deploy application
echo "🚢 Deploying e-commerce API..."
cd ../kubernetes/ecommerce-api
helm upgrade --install ecommerce-api . --namespace ecommerce --create-namespace

# Wait for deployment
echo "⏳ Waiting for application to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/ecommerce-api -n ecommerce

# Get service information
API_SERVICE_IP=$(kubectl get svc ecommerce-api -n ecommerce -o jsonpath='{.spec.clusterIP}')
PROMETHEUS_IP=$(kubectl get svc prometheus -n monitoring -o jsonpath='{.spec.clusterIP}')
GRAFANA_IP=$(kubectl get svc grafana -n monitoring -o jsonpath='{.spec.clusterIP}')

echo "🎉 Deployment completed successfully!"
echo ""
echo "📋 Service Information:"
echo "  E-commerce API:     http://$API_SERVICE_IP:8000"
echo "  Prometheus:         http://$PROMETHEUS_IP:9090"
echo "  Grafana:            http://$GRAFANA_IP:3000"
echo ""
echo "🔗 To access services:"
echo "  kubectl port-forward svc/ecommerce-api 8000:8000 -n ecommerce"
echo "  kubectl port-forward svc/prometheus 9090:9090 -n monitoring"
echo "  kubectl port-forward svc/grafana 3000:3000 -n monitoring"
echo ""
echo "📖 Check the README.md for more information"