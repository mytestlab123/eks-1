#!/bin/bash

CLUSTER_NAME="dev-eks-cluster"
REGION="ap-southeast-1"

# Create EKS cluster
aws eks create-cluster \
  --name $CLUSTER_NAME \
  --version 1.28 \
  --role-arn arn:aws:iam::273828039634:role/eks-service-role \
  --resources-vpc-config subnetIds=subnet-xxx,subnet-yyy

# Wait for cluster to be active
aws eks wait cluster-active --name $CLUSTER_NAME

# Create node group
aws eks create-nodegroup \
  --cluster-name $CLUSTER_NAME \
  --nodegroup-name dev-nodes \
  --subnets subnet-xxx subnet-yyy \
  --node-role arn:aws:iam::273828039634:role/NodeInstanceRole \
  --instance-types t3.medium \
  --scaling-config minSize=1,maxSize=3,desiredSize=2
