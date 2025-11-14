set shell := ["bash", "-lc"]

TF_DIR := "terraform/eks-mongodb"
ADDON_DIR := "terraform/addons/ebs-csi"

plan:
    cd {{TF_DIR}} && terraform init -input=false && terraform plan -var-file="dev.tfvars"

apply:
    cd {{TF_DIR}} && terraform apply -auto-approve -var-file="dev.tfvars"

addons-plan:
    cd {{ADDON_DIR}} && terraform init -input=false && terraform plan -var-file="dev.tfvars"

addons:
    cd {{ADDON_DIR}} && terraform apply -auto-approve -var-file="dev.tfvars"

test:
    cd {{TF_DIR}} && terraform init -input=false && terraform validate

docs:
    cat TASKS.md

next:
    echo "Next: stage private-only profile (network_profile=private-only) + Nexus proxy prep."

env:
    cat .env

kubeconfig:
    aws eks update-kubeconfig --region ap-southeast-1 --profile dev --name dev-mongodb-eks --kubeconfig ~/.kube/dev-mongodb-eks
    export KUBECONFIG=~/.kube/dev-mongodb-eks && kubectl config current-context && kubectl config view --minify
