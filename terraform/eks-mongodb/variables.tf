variable "environment" {
  description = "Deployment target (dev, prod, etc.)"
  type        = string
  default     = "dev"
}

variable "network_profile" {
  description = "Network posture. Options: public, private-only"
  type        = string
  default     = "public"
}

variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use when managing the cluster"
  type        = string
  default     = "dev"
}

variable "resource_prefix" {
  description = "Shorthand used as a prefix for all AWS resources"
  type        = string
  default     = "cdx"
}

variable "resource_tags" {
  description = "Additional tags merged into every resource"
  type        = map(string)
  default     = {}
}

variable "availability_zones" {
  description = "AZs to spread the VPC subnets across"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

variable "vpc_cidr" {
  description = "CIDR block for the new VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "CIDRs for the public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "private_subnets" {
  description = "CIDRs for the private subnets (used by node groups and control plane)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable a NAT for outbound access from private subnets"
  type        = bool
  default     = true
}

variable "cluster_version" {
  description = "EKS Kubernetes control plane version"
  type        = string
  default     = "1.28"
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "Allowed CIDRs for the public control plane endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_group_instance_types" {
  description = "Allowed EC2 instance types for the managed node group"
  type        = list(string)
  default     = ["t3.small"]
}

variable "node_group_capacity_type" {
  description = "Capacity type for the managed node group"
  type        = string
  default     = "SPOT"
}

variable "node_group_min_size" {
  description = "Minimum node count"
  type        = number
  default     = 2
}

variable "node_group_max_size" {
  description = "Maximum node count"
  type        = number
  default     = 2
}

variable "node_group_desired_size" {
  description = "Desired node count"
  type        = number
  default     = 2
}

variable "node_group_disk_size" {
  description = "Root disk size (GiB) for the managed node group"
  type        = number
  default     = 20
}

variable "node_group_labels" {
  description = "Labels passed to the node group for selection"
  type        = map(string)
  default = {
    role = "mongodb"
  }
}
