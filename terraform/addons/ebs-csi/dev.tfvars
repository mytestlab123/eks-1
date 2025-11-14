cluster_name = "dev-mongodb-eks"
region       = "ap-southeast-1"
aws_profile  = "dev"
tags = {
  Environment = "dev"
  Project     = "mongodb-demo"
  ProvisionedBy = "cdx"
  Name = "cdx-ebs-csi-driver"
}
