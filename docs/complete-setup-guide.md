# Complete EKS MongoDB Setup Guide

## Lessons Learned & Solutions

### Issues Encountered & Solutions
1. **EKS Endpoint Access**: Default private access blocks kubectl → Set public access
2. **EBS CSI Driver**: Missing driver prevents PVC provisioning → Install with proper IAM
3. **IAM Permissions**: Node group lacks EBS permissions → Configure IRSA for CSI driver
4. **MongoDB Operator**: Complex multi-replica setup issues → Start with single replica

### Optimal Configuration
- **EKS Endpoint**: Public access enabled
- **EBS CSI Driver**: Installed with IRSA (IAM Roles for Service Accounts)
- **MongoDB**: Single replica for learning, simple configuration
- **Resources**: Minimal CPU/memory for cost optimization

## Complete Setup Process

### Step 1: Infrastructure (Terraform)
```hcl
# Key settings for EKS cluster
endpoint_config {
  private_access = false
  public_access  = true
  public_access_cidrs = ["0.0.0.0/0"]
}

# EBS CSI driver addon with IRSA
aws_eks_addon "ebs_csi" {
  cluster_name             = aws_eks_cluster.mongodb_demo.name
  addon_name              = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn
}

# IAM role for EBS CSI driver
resource "aws_iam_role" "ebs_csi_driver" {
  name = "AmazonEKS_EBS_CSI_DriverRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}
```

### Step 2: MongoDB Deployment
```yaml
# Optimal MongoDB configuration
apiVersion: mongodbcommunity.mongodb.com/v1
kind: MongoDBCommunity
metadata:
  name: mongodb-demo
spec:
  members: 1                    # Single replica for learning
  type: ReplicaSet
  version: "6.0.5"             # Stable version
  security:
    authentication:
      modes: ["SCRAM"]
  users:
    - name: admin
      db: admin
      passwordSecretRef:
        name: admin-password
      roles:
        - name: clusterAdmin
          db: admin
  statefulSet:
    spec:
      template:
        spec:
          containers:
            - name: mongod
              resources:
                limits:
                  cpu: "200m"      # Minimal resources
                  memory: "256Mi"
                requests:
                  cpu: "100m"
                  memory: "128Mi"
```

### Step 3: Verification Commands
```bash
# 1. Check cluster access
kubectl get nodes

# 2. Verify EBS CSI driver
kubectl get pods -n kube-system | grep ebs-csi

# 3. Check MongoDB deployment
kubectl get mongodbcommunity
kubectl get pods

# 4. Test MongoDB connection
kubectl exec -it mongodb-demo-0 -c mongod -- mongosh --username admin --password admin123 --authenticationDatabase admin
```

## Cost Optimization
- **Spot Instances**: t3.small spot nodes (~$0.30/day)
- **Minimal Resources**: 200m CPU, 256Mi memory per container
- **Single Replica**: Reduces resource usage
- **Total Cost**: ~$0.60/day

## Success Criteria
✅ kubectl access working
✅ EBS volumes provisioning
✅ MongoDB operator running
✅ MongoDB accepting connections
✅ Cost under $1/day
