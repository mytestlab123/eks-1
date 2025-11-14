# Runbook & Tasks

## 1. Dev profile: public VPC + EKS (starting 13 Nov 2025)

| Item | Details |
| --- | --- |
| **Goal** | Stand up a *new*, public-facing VPC (prefixed `cdx-`) and EKS cluster using the existing Terraform code so we can iterate on MongoDB Operator work in the dev account. |
| **Env vars** | Set `ENV=dev` and `OS_VERSION=Amazon Linux 2023` in `.env`; this is the canonical dev profile for the repo. |
| **Primary commands** | `just plan` → `just apply` (uses `terraform/eks-mongodb` with `dev` vars). |
| **Validation** | Confirm VPC/EKS outputs (`terraform output cluster_endpoint`) and `kubectl get nodes` once `aws eks update-kubeconfig` succeeds. |
| **Notes** | The Terraform code now creates a dev-named VPC with 3 public and private AZs, a NAT gateway, and a public-accessible control plane; MongoDB nodes still run in private subnets for safety. |

Steps:
1. `just plan` to validate changes and inspect which resources Terraform will create.
2. `just apply` to provision the VPC, subnets, NAT, and EKS cluster.
3. Update local kubeconfig via `just kubeconfig` (wraps `aws eks update-kubeconfig --kubeconfig ~/.kube/dev-mongodb-eks` and drops the context info) before installing the MongoDB operator manifests.
4. Record outputs/observations in `README.md` (Setup or Troubleshooting sections) if the dev test reveals adjustments.

## 1.5 Add-on sequencing (new)

| Item | Details |
| --- | --- |
| **Goal** | Apply OIDC/add-on resources only after the cluster is live so Terraform doesn’t keep recreating the same add-on when the default 20 min timeout expires. |
| **New directory** | `terraform/addons/ebs-csi/` (manages the `aws-ebs-csi-driver` add-on) |
| **Workflow** | 1. `just apply` (cluster) → 2. `just addons` (installs the CSI driver once the cluster exists; `just addons-plan` can be used to preview) <br/> 3. Confirm with `aws eks describe-addon` and `kubectl -n kube-system get pods` |
| **Timeouts/Tags** | The addon module now sets `timeouts { create = "30m" }` and tags the add-on with `Environment=dev` + `Project=mongodb-demo`. |
| **Manual fallback** | `aws eks create-addon ...` can be used if the Terraform module still struggles; running it separately keeps the main stack intact. |

## 1.6 Teardown checklist

| Item | Details |
+| --- | --- |
| **Goal** | Ensure the dev stack is cleaned up before switching context or burning costs. |
| **Commands** | 1. `cd terraform/addons/ebs-csi && terraform destroy -auto-approve -var-file=dev.tfvars` <br> 2. `cd terraform/eks-mongodb && terraform destroy -auto-approve -var-file=dev.tfvars` |
| **Verification** | Check `aws eks list-clusters --profile dev` or `terraform state list` to ensure `dev-mongodb-eks` is gone, and confirm the `cdx-dev-` VPC is removed from `aws ec2 describe-vpcs`. |


## 2. Production-ready “private only” future work

| Item | Details |
| --- | --- |
| **Goal** | Reuse the same IaC with a `network_profile = "private-only"` so production runs in a private-only VPC that relies on Nexus/Quay proxies instead of the public Internet. |
| **Actionables** | - Mirror all container images into the Nexus proxy. <br> - Add imagePullSecrets to MongoDB Operator manifests. <br> - Attach the Nexus proxy (reachable via Transit Gateway or private endpoint) before applying prod Terraform. |
| **Terraform changes** | The module already allows toggling NAT, endpoint visibility, and CIDRs; simply switch to `enable_nat_gateway = false`, `cluster_endpoint_public_access = false`, and a private-only `network_profile`. |
| **Runbook notes** | - Ensure VPC endpoints for ECR, S3, STS, Secrets Manager, Systems Manager, and ACM are created. <br> - Set SSM patching to `RebootOption=NoReboot`. <br> - Document rollout failures (and Nexus proxy prep) directly in `README.md` or `TASKS.md` as they happen.

## 3. Current assumptions

- Dev account has permissions for new VPC subnets, NAT, and EKS clusters in `ap-southeast-1`.
- `aws configure --profile dev` exists and is used by Terraform via `var.aws_profile`.
- MongoDB manifests will eventually reference Nexus imagePullSecrets once the private profile is tested.
