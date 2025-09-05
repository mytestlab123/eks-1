terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "dev-eks-cluster"
  cluster_version = "1.28"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    dev_nodes = {
      min_size     = 2
      max_size     = 2
      desired_size = 2

      instance_types = ["t3.small"]
      capacity_type  = "SPOT"
      
      disk_size = 20
    }
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "dev-eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-southeast-1a", "ap-southeast-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    "kubernetes.io/cluster/dev-eks-cluster" = "shared"
  }
}
