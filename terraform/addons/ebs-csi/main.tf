locals {
  tag_map = merge(
    {
      Environment = "dev"
      Project     = "mongodb-demo"
    },
    var.tags
  )
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name                = var.cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = var.addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  preserve                    = false

  tags = local.tag_map

  timeouts {
    create = var.create_timeout
  }
}
