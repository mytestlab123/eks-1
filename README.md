# EKS MongoDB Operator Demo

Cost-effective EKS cluster with MongoDB Community Operator for learning and development.

## 🎯 Project Overview

This project demonstrates deploying MongoDB Community Operator on Amazon EKS with:
- **Cost-optimized infrastructure** (~$0.60/day)
- **Spot instances** for development workloads
- **Complete automation** with Terraform
- **Production-ready patterns** for learning

## 🚀 Quick Start

```bash
# 1. Deploy infrastructure
cd terraform/eks-mongodb
terraform init && terraform apply

# 2. Configure kubectl
aws eks update-kubeconfig --region ap-southeast-1 --name mongodb-demo-eks

# 3. Install MongoDB Operator
kubectl apply -f https://raw.githubusercontent.com/mongodb/mongodb-kubernetes-operator/master/config/crd/bases/mongodbcommunity.mongodb.com_mongodbcommunity.yaml
kubectl apply -f https://raw.githubusercontent.com/mongodb/mongodb-kubernetes-operator/master/config/manager/manager.yaml

# 4. Deploy MongoDB
kubectl apply -f kubernetes/mongodb/mongodb-simple-working.yaml
```

## 📁 Project Structure

```
├── terraform/eks-mongodb/     # Infrastructure as Code
├── kubernetes/mongodb/        # MongoDB manifests
├── docs/                     # Comprehensive guides
└── scripts/                  # Utility scripts
```

## 📚 Documentation

- **[Complete Setup Guide](docs/complete-setup-guide.md)** - Full deployment walkthrough
- **[MongoDB Operator Guide](docs/mongodb-operator-guide.md)** - Learning exercises
- **[PROJECT.md](PROJECT.md)** - Current status and progress

## 💰 Cost Optimization

- **EKS Control Plane**: $0.10/hour ($2.40/day)
- **Worker Nodes**: 2x t3.small spot (~$0.60/day total)
- **Storage**: Minimal EBS usage
- **Total**: ~$3.00/day for learning environment

## 🔧 Key Features

- ✅ **Infrastructure-only Terraform** (no Kubernetes resource conflicts)
- ✅ **EBS CSI Driver** with proper IRSA configuration
- ✅ **MongoDB Community Operator** with RBAC
- ✅ **Spot instances** for cost optimization
- ✅ **Complete cleanup** with `terraform destroy`

## 🎓 Learning Outcomes

- EKS cluster management and access control
- Kubernetes operators and CRDs
- MongoDB deployment patterns
- Infrastructure automation with Terraform
- Cost optimization strategies

## 📊 Status

**Current**: Infrastructure destroyed, ready for redeployment
**Last Tested**: 2025-09-05
**Deployment Time**: ~15 minutes total

---

**AWS Account**: 273828039634 (dev)  
**Region**: ap-southeast-1
