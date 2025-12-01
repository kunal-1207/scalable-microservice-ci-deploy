# Provider configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# VPC Configuration
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "${var.project_name}-cluster"
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    general = {
      desired_size = var.desired_capacity
      min_size     = var.min_capacity
      max_size     = var.max_capacity

      instance_types = var.instance_types
      capacity_type  = "ON_DEMAND"
    }
  }

  # Enable cluster logging
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Enable OIDC provider for IRSA
  enable_irsa = true

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# S3 bucket for application storage
resource "aws_s3_bucket" "app_bucket" {
  bucket = "${var.project_name}-${var.environment}-storage"

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_s3_bucket_versioning" "app_bucket_versioning" {
  bucket = aws_s3_bucket.app_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# CloudWatch Log Group for application logs
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/eks/${var.project_name}/application"
  retention_in_days = 30

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# IAM role for EKS nodes (additional permissions if needed)
resource "aws_iam_role_policy_attachment" "nodes_s3_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = module.eks.eks_managed_node_groups["general"].iam_role_name
}

# Outputs
output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster certificate authority data"
  value       = module.eks.cluster_certificate_authority_data
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.app_bucket.bucket
}