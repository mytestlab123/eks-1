variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "vpc_id" {
  description = "Existing VPC ID to use"
  type        = string
  default     = "vpc-035eb12babd9ca798"
}

variable "key_pair_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
  default     = "amit"
}
