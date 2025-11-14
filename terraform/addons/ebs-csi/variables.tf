variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "region" {
  description = "AWS region where the cluster lives"
  type        = string
  default     = "ap-southeast-1"
}

variable "aws_profile" {
  description = "AWS CLI profile for operations"
  type        = string
  default     = "dev"
}

variable "addon_version" {
  description = "Version of the aws-ebs-csi-driver add-on"
  type        = string
  default     = "v1.52.1-eksbuild.1"
}

variable "create_timeout" {
  description = "Timeout for addon creation"
  type        = string
  default     = "30m"
}

variable "tags" {
  description = "Additional tags to apply to the add-on"
  type        = map(string)
  default     = {}
}
