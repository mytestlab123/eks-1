# AGENTS.md — EKS MongoDB Demo guidance

## Purpose
- Capture the current strategies (dev public cluster + downstream add-on) and the commands preferred for this repo.

## Key Concepts
- Infrastructure runs via `terraform/eks-mongodb` for the dev cluster and `terraform/addons/ebs-csi` for the CSI driver; keep the cluster stack separate so Terraform never has to retry long add-on creations.
- Prefix/tag hygiene is applied only to network resources (VPC + supporting networking tags) and shared tags, while the cluster keeps its existing `dev-mongodb-eks` name so other projects are unaffected.
- Add-on provisioning now happens through `just addons` once the cluster is ready; the add-on module waits 30 minutes for `aws-ebs-csi-driver` and tags the resource for dev tracking.
- Node IAM roles need the `ec2:DescribeAvailabilityZones` policy (`terraform/eks-mongodb/main.tf`), and the managed node group attaches it through `iam_role_additional_policies`.

## Workflows
- **Cluster creation/reconfigure**: `just plan` → `just apply`.
- **Add-on provisioning**: `just addons-plan` → `just addons` (runs the dedicated module with a 30 min timeout) once the cluster is active.
- **Kubeconfig**: `just kubeconfig` writes to `~/.kube/dev-mongodb-eks` and exports `KUBECONFIG` before running `kubectl`, keeping contexts in sync.
- **Testing**: `just test` runs `terraform init -input=false` + `terraform validate` to check syntax.
- **Tear-down**: run `cd terraform/addons/ebs-csi && terraform destroy -auto-approve -var-file=dev.tfvars` followed by `cd terraform/eks-mongodb && terraform destroy -auto-approve -var-file=dev.tfvars` so the AWS resources are removed cleanly when you finish.

## Documentation & Notes
- Use `TASKS.md` for runbooks and future plans (private-only, Nexus proxy, etc.).
- Keep `README.md` updated with quick start, cost profile, and link back to the `just` targets/nexus plan in `TASKS.md`.
- Avoid creating additional doc folders; this repo should only include `AGENTS.md`, `TASKS.md`, and `README.md`.
