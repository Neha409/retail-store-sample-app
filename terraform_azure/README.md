# AKS + ArgoCD + NGINX Ingress + cert-manager (Terraform)

## What this creates
- Resource group + Log Analytics workspace
- AKS cluster (system-assigned identity, autoscaling node pool, Azure CNI,
  OIDC issuer + workload identity enabled, Azure Policy add-on, monitoring)
- Via Helm (deployed straight after the cluster, using the AKS kube_config output):
  - **ingress-nginx** — LoadBalancer-backed ingress controller
  - **cert-manager** — with a `letsencrypt-prod` ClusterIssuer (HTTP-01 via nginx)
  - **Argo CD** — exposed through the nginx Ingress, TLS via cert-manager

## Files
| File | Purpose |
|---|---|
| `versions.tf` | Provider requirements + kubernetes/helm provider wiring off the AKS output |
| `variables.tf` | All configurable inputs (sizes, versions, toggles) |
| `main.tf` | Resource group, Log Analytics, AKS cluster |
| `addons.tf` | Namespaces + Helm releases for nginx, cert-manager, Argo CD, ClusterIssuer |
| `outputs.tf` | Useful outputs (kubeconfig, admin password command, etc.) |
| `terraform.tfvars.example` | Sample variable values — copy to `terraform.tfvars` |

## Prerequisites
- Terraform >= 1.5
- Azure CLI, logged in (`az login`) with a subscription selected (`az account set --subscription <id>`)
- Sufficient quota for the chosen VM size/count in your region

## Usage
```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars: prefix, location, acme_email, sizes, etc.

terraform init
terraform plan
terraform apply
```

Get kubeconfig locally (optional, Terraform already wires providers internally):
```bash
az aks get-credentials --resource-group <rg-name> --name <cluster-name> --overwrite-existing
```

Get the Argo CD initial admin password:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d; echo
```

Get the public IP of the ingress controller (point your DNS `A` record at this):
```bash
kubectl -n ingress-nginx get svc ingress-nginx-controller \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

## Important things to customize before production use
1. **`argocd.example.com`** in `addons.tf` (`server.ingress.hostname`) — point this
   at a real domain whose DNS you control, resolving to the nginx ingress IP above.
2. **`acme_email`** — used by Let's Encrypt for expiry/abuse notices.
3. **VM size / node counts** — `Standard_D2s_v5` x 3 is a reasonable dev default;
   size up for production workloads.
4. **Network model** — this uses Azure CNI (`network_plugin = "azure"`) with the
   `azure` network policy. Switch to `kubenet` in `variables.tf` if you have IP
   address space constraints.
5. Consider enabling **private cluster** (`private_cluster_enabled = true` on the
   `azurerm_kubernetes_cluster` resource) if the API server should not be public.
6. Argo CD is deployed with `server.extraArgs = ["--insecure"]` because TLS is
   terminated at the nginx ingress. If you want TLS all the way to the Argo CD
   pod instead, remove that flag and switch the ingress to `passthrough` mode.
7. Chart versions are pinned in `variables.tf` (`nginx_chart_version`,
   `cert_manager_chart_version`, `argocd_chart_version`) — bump deliberately.

## Notes
- The `kubernetes`/`helm` providers are configured directly from the
  `azurerm_kubernetes_cluster.aks.kube_config` output, so `terraform apply`
  can create the cluster *and* install the addons in a single run — no manual
  `az aks get-credentials` step needed in between.
- Each addon can be disabled independently via `enable_nginx_ingress`,
  `enable_cert_manager`, `enable_argocd` in `variables.tf`.
- `terraform validate`/`init` could not be run in the environment that
  generated this code (no network access) — run both yourself before `apply`.
