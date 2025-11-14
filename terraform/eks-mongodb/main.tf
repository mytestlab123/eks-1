locals {
  resource_prefix = trimspace(length(trimspace(var.resource_prefix)) == 0 ? "cdx" : var.resource_prefix)
  vpc_name        = "${local.resource_prefix}-${var.environment}-mongodb-vpc"
  cluster_name    = "${var.environment}-mongodb-eks"

  shared_tags = merge(
    {
      Environment   = var.environment
      Project       = "mongodb-demo"
      ProvisionedBy = local.resource_prefix
    },
    var.resource_tags
  )

  is_private_network            = var.network_profile == "private-only"
  cluster_public_access_enabled = !local.is_private_network
  cluster_public_access_cidrs   = local.cluster_public_access_enabled ? var.cluster_endpoint_public_access_cidrs : []
}

resource "aws_iam_policy" "node_ec2_describe_az" {
  name        = "${local.resource_prefix}-${local.cluster_name}-node-ec2-describe-az"
  description = "Allow node IAM role to describe Availability Zones for CSI driver health checks"
  path        = "/${local.resource_prefix}/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["ec2:DescribeAvailabilityZones"]
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.vpc_name
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = var.enable_nat_gateway
  enable_vpn_gateway = false
  single_nat_gateway = true

  tags = merge(local.shared_tags, { Name = local.vpc_name })
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = local.cluster_public_access_enabled
  cluster_endpoint_public_access_cidrs = local.cluster_public_access_cidrs

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    mongodb_nodes = {
      instance_types = var.node_group_instance_types
      capacity_type  = var.node_group_capacity_type

      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size
      desired_size = var.node_group_desired_size

      disk_size = var.node_group_disk_size

      labels = var.node_group_labels

      iam_role_additional_policies = {
        "ec2-describe-az" = aws_iam_policy.node_ec2_describe_az.arn
        "ec2-volume"      = aws_iam_policy.node_ec2_volume.arn
      }
    }
  }

  tags = merge(local.shared_tags, { Name = local.cluster_name })
}

resource "aws_iam_policy" "node_ec2_volume" {
  name        = "${local.resource_prefix}-${local.cluster_name}-node-ec2-volume"
  description = "Allow nodes to create and manage EC2 volumes for MongoDB PVs"
  path        = "/${local.resource_prefix}/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateVolume",
          "ec2:DeleteVolume",
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:ModifyVolume",
          "ec2:DescribeVolumes",
          "ec2:DescribeVolumeStatus",
          "ec2:DescribeInstanceAttribute",
        "ec2:DescribeInstanceStatus",
        "ec2:CreateTags",
        "ec2:DeleteTags"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}


output "environment" {
  description = "Deployment environment"
  value       = var.environment
}

output "network_profile" {
  description = "Network posture"
  value       = var.network_profile
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Control plane endpoint URL"
  value       = module.eks.cluster_endpoint
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "Private subnet IDs used by EKS"
  value       = module.vpc.private_subnets
}

output "region" {
  description = "AWS region"
  value       = var.region
}
