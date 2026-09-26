# Retail Store Sample App - GitOps with Amazon EKS Auto Mode
 
![Banner](./docs/images/banner.png)

<div align="center">
  <div align="center">

[![Stars](https://img.shields.io/github/stars/LondheShubham153/retail-store-sample-app)](Stars)
![GitHub License](https://img.shields.io/github/license/LondheShubham153/retail-store-sample-app?color=green)
![Dynamic JSON Badge](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%LondheShubham153%2Fretail-store-sample-app%2Frefs%2Fheads%2Fmain%2F.release-please-manifest.json&query=%24%5B%22.%22%5D&label=release)

  </div>

  <strong>
  <h2>Azure Containers Retail Sample</h2>
  </strong>
</div>

This is a sample application designed to illustrate various concepts related to containers on Azure. It presents a sample retail store application including a product catalog, shopping cart and checkout, deployed using modern DevOps practices including GitOps and Infrastructure as Code.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Branch Strategy](#branch-strategy)
- [Getting Started](#getting-started)
- [GitOps Workflow](#gitops-workflow)
- [AKS Cluster](#aks-cluster)
- [Infrastructure Components](#infrastructure-components)
- [CI/CD Pipeline](#cicd-pipeline)
- [Monitoring and Observability](#monitoring-and-observability)
- [Cleanup](#step-12-cleanup)
- [Troubleshooting](#troubleshooting)

## Overview

The Retail Store Sample App demonstrates a modern microservices architecture deployed on Azure Kubernetes Service (AKS) using GitOps principles. The application consists of multiple services that work together to provide a complete retail store experience:

- **UI Service**: Java-based frontend
- **Catalog Service**: Go-based product catalog API
- **Cart Service**: Java-based shopping cart API
- **Orders Service**: Java-based order management API
- **Checkout Service**: Node.js-based checkout orchestration API

## Application Architecture

The application has been deliberately over-engineered to generate multiple de-coupled components. These components generally have different infrastructure dependencies, and may support multiple "backends" (example: Carts service supports MongoDB or Azure Cosmos DB).

![Architecture](https://github.com/aws-containers/retail-store-sample-app/raw/main/docs/images/architecture.png)

| Component                  | Language | Container Image                                                        | Helm Chart                             | Description                             |
| --------------------------- | -------- | ------------------------------------------------------------------------ | --------------------------------------- | ---------------------------------------- |
| [UI](./src/ui/)             | Java     | Azure Container Registry (ACR)                                          | [Link](src/ui/chart/values.yaml)        | Store user interface                    |
| [Catalog](./src/catalog/)   | Go       | Azure Container Registry (ACR)                                          | [Link](src/catalog/chart/values.yaml)   | Product catalog API                     |
| [Cart](./src/cart/)         | Java     | Azure Container Registry (ACR)                                          | [Link](src/cart/chart/values.yaml)      | User shopping carts API                 |
| [Orders](./src/orders)      | Java     | Azure Container Registry (ACR)                                          | [Link](src/orders/chart/values.yaml)    | User orders API                         |
| [Checkout](./src/checkout)  | Node     | Azure Container Registry (ACR)                                          | [Link](src/checkout/chart/values.yaml)  | API to orchestrate the checkout process |

> For a simple public/demo deployment you can also pull pre-built images from a public registry such as Docker Hub or the Microsoft Container Registry instead of standing up your own ACR — see [Branch Strategy](#branch-strategy).

## Infrastructure Architecture

The Infrastructure Architecture follows cloud-native best practices:

- **Microservices**: Each component is developed and deployed independently
- **Containerization**: All services run as containers on Kubernetes
- **GitOps**: Infrastructure and application deployment managed through Git (Argo CD)
- **Infrastructure as Code**: All Azure resources defined using Terraform
- **CI/CD**: Automated build and deployment pipelines with GitHub Actions

![AKS](docs/images/AKS.gif)

## Quick Start

**Want to deploy immediately?** Follow these steps for a basic deployment:

1. **Install Prerequisites**: Azure CLI, Terraform, kubectl, Docker, Helm
2. **Configure Azure**: `az login` with appropriate credentials
3. **Clone Repository**: `git clone https://github.com/LondheShubham153/retail-store-sample-app.git`
4. **Deploy Infrastructure**: Run Terraform in two phases (see [Getting Started](#getting-started))
5. **Access Application**: Get the ingress LoadBalancer IP and browse the retail store

**Need advanced GitOps workflow?** See [BRANCHING_STRATEGY.md](./BRANCHING_STRATEGY.md) for automated CI/CD setup.

## Branch Strategy

This repository uses a **dual-branch approach** for different deployment scenarios:

### 🌐 **Public Application (Main Branch)**
- **Purpose**: Simple deployment with public images
- **Images**: Public registry (stable versions like v1.2.2)
- **Deployment**: Manual control with umbrella chart
- **Updates**: Manual only
- **Best for**: Demos, learning, quick testing, simple deployments

### 🏭 **Production (GitOps Branch)**
- **Purpose**: Full production workflow with CI/CD pipeline
- **Images**: Private Azure Container Registry (auto-updated with commit hashes)
- **Deployment**: Automated via GitHub Actions
- **Updates**: Automatic on code changes
- **Best for**: Production environments, automated workflows, enterprise deployments

> **📚 For detailed branching strategy, CI/CD setup, and advanced workflows, see [BRANCHING_STRATEGY.md](./BRANCHING_STRATEGY.md)**

## Getting Started

### Prerequisites

1. **Install Prerequisites**: Azure CLI, Terraform, kubectl, Docker, Helm
2. **Configure Azure**: `az login`, then `az account set --subscription <subscription-id>`
3. **Clone Repository**: `git clone https://github.com/LondheShubham153/retail-store-sample-app.git`
4. **Deploy Infrastructure**: Run Terraform (see [Getting Started](#getting-started) below)
5. **Access Application**: Get the ingress LoadBalancer IP and browse the retail store

### **Required Tools**

| Tool          | Version | Installation                                                                          |
| ------------- | ------- | -------------------------------------------------------------------------------------- |
| **Azure CLI** | v2+     | [Install Guide](https://learn.microsoft.com/cli/azure/install-azure-cli)               |
| **Terraform** | 1.5+    | [Install Guide](https://developer.hashicorp.com/terraform/install)                     |
| **kubectl**   | 1.28+   | [Install Guide](https://kubernetes.io/docs/tasks/tools/)                               |
| **Docker**    | 20.0+   | [Install Guide](https://docs.docker.com/get-docker/)                                   |
| **Helm**      | 3.0+    | [Install Guide](https://helm.sh/docs/intro/install/)                                   |
| **Git**       | 2.0+    | [Install Guide](https://git-scm.com/downloads)                                         |

### **Quick Installation Scripts**

<details>
<summary><strong>🔧 One-Click Installation</strong></summary>

```bash
#!/bin/bash
# Install all prerequisites

# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# kubectl
curl -LO "https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify installations
az --version
terraform --version
kubectl version --client
docker --version
helm version
```

</details>

## Follow these steps to deploy the application:

### Step 1. Configure Azure CLI:

Log in and select the subscription you want to deploy into:

```sh
az login
az account set --subscription <subscription-id>
```

### Step 2. Clone the Repository:

```sh
git clone https://github.com/Neha409/retail-store-sample-app.git
```

> [!IMPORTANT]
> ### Step 3: Choose Your Deployment Strategy
>
> **For Public Application (Main Branch):**
> - Uses stable public images (v1.2.2)
> - Manual deployment control
> - No GitHub Actions required
> - Skip to Step 4 - infrastructure is ready
>
> **For Production (GitOps Branch):**
> - Uses private Azure Container Registry with automated CI/CD
> - Requires GitHub Actions setup
> - See [BRANCHING_STRATEGY.md](./BRANCHING_STRATEGY.md) for complete setup

### Step 4. Deploy Infrastructure with Terraform:

```sh
cd retail-store-sample-app/terraform/
terraform init
terraform apply --auto-approve
```

> If this is the very first apply, the `kubernetes`/`helm` providers may need
> the AKS cluster to exist before they can be configured. If you hit a
> provider-configuration error, apply in two steps:
> ```sh
> terraform apply -target=azurerm_kubernetes_cluster.aks --auto-approve
> terraform apply --auto-approve
> ```

This creates the core infrastructure, including:
- Resource group and Azure Log Analytics workspace
- Azure Kubernetes Service (AKS) cluster with autoscaling node pools
- Azure networking (VNet/subnets), managed identities, and RBAC

And deploys:
- Argo CD for GitOps
- NGINX Ingress Controller
- cert-manager for SSL/TLS certificates

### Step 5: Update kubeconfig to Access the AKS Cluster:

```sh
az aks get-credentials --resource-group <resource-group-name> --name <aks-cluster-name> --overwrite-existing
```

> Application is live with the public image set:

- Get your ingress `EXTERNAL-IP` and paste it in the browser to access the retail-store application:
    ```sh
    kubectl get svc -n ingress-nginx
    ```

> [!NOTE]
> Let's move forward with GitOps principles, utilizing Azure Container Registry (ACR) as our private registry to store images.

### Step 6: GitHub Actions (Production Branch Only)

> **Note**: This step is only required if you're using the **Production branch** for automated deployments. Skip this step if using the **Public Application branch** for simple deployment.

For GitHub Actions, first configure secrets so the pipelines can be automatically triggered. The recommended approach is an Azure **service principal** with federated credentials (OIDC), avoiding long-lived secrets:

```sh
az ad sp create-for-rbac \
  --name "retail-store-github-actions" \
  --role contributor \
  --scopes /subscriptions/<subscription-id>/resourceGroups/<resource-group-name> \
  --sdk-auth
```

**Go to your GitHub repo → Settings → Secrets and variables → Actions → New repository secret.**

| Secret Name             | Value                                          |
| ------------------------ | ----------------------------------------------- |
| `AZURE_CLIENT_ID`         | Service principal / app registration client ID |
| `AZURE_TENANT_ID`         | Azure AD tenant ID                             |
| `AZURE_SUBSCRIPTION_ID`   | Your Azure subscription ID                     |
| `ACR_LOGIN_SERVER`        | e.g. `retailstoreacr.azurecr.io`               |
| `AZURE_RESOURCE_GROUP`    | Your resource group name                       |

> [!IMPORTANT]
> Once the entire cluster is created, any changes pushed to the repository will automatically trigger GitHub Actions.

GitHub Actions will automatically build and push the updated Docker images to Azure Container Registry (ACR).

### Verify Deployment

Check if the nodes are running:

```bash
kubectl get nodes
```

### Step 7: Access the Application:

The application is exposed through the NGINX Ingress Controller. Get the load balancer IP:

```bash
kubectl get svc -n ingress-nginx
```

Use the `EXTERNAL-IP` of the `ingress-nginx-controller` service to access the application.

### Step 8: Argo CD Automated Deployment:

**Verify Argo CD installation**

```sh
kubectl get pods -n argocd
```

### Step 9: Port-forward to Argo CD UI and login:

**Get Argo CD admin password**
```sh
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

**Port-forward to Argo CD UI**
```sh
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
```

Open your browser and navigate to:
https://localhost:8080

Username: `admin`

Password: `<output of previous command>`

### Step 10: Access ArgoCD UI

Once Argo CD is deployed, you can access the web interface:

![ArgoCD UI Dashboard](./docs/images/argocd-ui.png)

The ArgoCD UI provides:
- **Application Status**: Real-time sync status of all services
- **Resource View**: Detailed view of Kubernetes resources
- **Sync Operations**: Manual sync and rollback capabilities
- **Health Monitoring**: Application and resource health status

### Step 11: Monitor Application Deployment

```bash
kubectl get pods -n retail-store
kubectl get ingress -n retail-store
```

### Step 12: Cleanup

To delete all resources created by Terraform:

```sh
terraform destroy --auto-approve
```

> [!NOTE]
> Azure Container Registry (ACR) repositories/images may need to be deleted separately from the Azure Portal or via `az acr repository delete` if you don't want Terraform managing the registry lifecycle.

## Troubleshooting

### Common Issues

#### **Image Pull Errors**
```
Error: Failed to pull image "retailstoreacr.azurecr.io/retail-store-ui:abc1234"
```
**Solutions**:
1. Ensure you're using the correct branch for your deployment strategy
2. For Production branch: Check GitHub Actions completed successfully and pushed to ACR
3. For Public Application branch: Verify you're using the public image references
4. Check that AKS has `AcrPull` permission on the registry:
   ```sh
   az aks update -n <aks-cluster-name> -g <resource-group-name> --attach-acr <acr-name>
   ```

#### **GitHub Actions Not Triggering**
**Solutions**:
1. Ensure changes are in the `src/` directory
2. Verify you're on the `production` branch (gitops)
3. Check GitHub Actions is enabled in repository settings
4. Confirm the federated credential / service principal secrets are correctly set
5. Review [BRANCHING_STRATEGY.md](./BRANCHING_STRATEGY.md) for detailed setup

### Getting Help

- **Basic deployment issues**: Check this README
- **Advanced GitOps issues**: See [BRANCHING_STRATEGY.md](./BRANCHING_STRATEGY.md)
- **Infrastructure issues**: Review Terraform logs (`terraform plan`/`apply` output)
- **Application issues**: Check ArgoCD UI and `kubectl logs`

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](./LICENSE) file for details.

## Support

- **Issues**: [GitHub Issues](https://github.com/LondheShubham153/retail-store-sample-app/issues)
- **Discord**: [TrainWithShubhamCommunity](https://discord.gg/kGEr9mR5gT)

---

<div align="center">

**⭐ Star this repository if you found it helpful!**

**🔄 For advanced GitOps workflows, see [BRANCHING_STRATEGY.md](./BRANCHING_STRATEGY.md)**

</div>
