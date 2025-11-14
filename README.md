# EKS MongoDB Operator Demo

Cost-optimized EKS + MongoDB Community Operator deployments in ap-southeast-1, now with `cdx-` prefix/tag hygiene so both repos can coexist cleanly.

## Quick workflow

| Step | Command |
| --- | --- |
| Validate IaC | `just test` |
| Preview cluster | `just plan` |
| Apply cluster | `just apply` |
| Sync kubeconfig | `just kubeconfig` |
| Deploy addon | `just addons-plan` → `just addons` |
| Tear down | `cd terraform/addons/ebs-csi && terraform destroy -auto-approve -var-file=dev.tfvars` → `cd terraform/eks-mongodb && terraform destroy -auto-approve -var-file=dev.tfvars` |

`just addons` still owns `terraform/addons/ebs-csi`, so the CSI driver installs after the cluster is healthy; use the tear-down steps whenever you finish work to keep AWS clean.

## Status snapshot (current state: destroyed)

- Cluster: `dev-mongodb-eks` (destroyed; re-run `just apply`/`just addons` to rebuild).  
- VPC: `cdx-dev-mongodb-vpc` (destroyed; tags/provisioner defined in `terraform/eks-mongodb`).  
- Add-on: `aws-ebs-csi-driver` (destroyed; `just addons` reinstalls it with a 30 min create timeout).  
- MongoDB sample: `mongodb-simple` (namespace `mongodb`) was deployed during testing but its PVC failed because the managed nodes could not tag volumes even though the role has the `ec2:CreateVolume/CreateTags` policy. Also the init images require access to Quay (401); mirror or supply credentials before redeploying.

## Documentation

- `AGENTS.md`: operating notes, prefix/tag guidance, and destroy workflow for Codex.  
- `TASKS.md`: runbook for the dev public VPC/EKS build, add-on sequencing, and the private-only/Nexus plan.

Re-run the quick workflow when you next want the cluster. Record any new fallback steps (e.g., private registry pull secrets or SSM patch routines) in `TASKS.md` before shifting the configuration into production.
