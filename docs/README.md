# EKS MongoDB Demo

## Overview
Cost-effective EKS cluster for MongoDB Community Operator learning.

## Architecture
- **EKS Cluster**: mongodb-demo-eks
- **Nodes**: 2x t3.small spot instances
- **MongoDB**: Community v7, 2-replica set
- **Storage**: Ephemeral (no EBS costs)
- **Cost**: ~$0.60/day

## Quick Start
```bash
cd terraform/eks-mongodb
terraform init
terraform apply
```

## MongoDB Setup
```bash
# Configure kubectl
aws eks update-kubeconfig --profile dev --region ap-southeast-1 --name mongodb-demo-eks

# Install MongoDB operator
kubectl apply -f ../../kubernetes/mongodb/crd.yaml
kubectl apply -f ../../kubernetes/mongodb/operator.yaml

# Deploy MongoDB replica set
kubectl apply -f ../../kubernetes/mongodb/mongodb-replica.yaml

# Check status
kubectl get pods -n mongodb
kubectl get mongodbcommunity -n mongodb
```

## Demo Operations
```bash
# Connect to MongoDB
kubectl exec -it mongodb-replica-set-0 -n mongodb -- mongosh --username admin --password admin123

# Basic operations
use testdb
db.users.insertOne({name: "test", age: 30})
db.users.find()
```

## Cleanup
```bash
terraform destroy
```
