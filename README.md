# 🚀 Kubernetes Event-Driven Autoscaler (KEDA) Manager

This script automates operations on a bare Kubernetes cluster, including connecting to the cluster, installing necessary tools (Helm, KEDA), deploying applications with event-driven scaling, and retrieving health status for deployments.

---

## ✨ Features

- **Connect to the Kubernetes Cluster**: Establish connection to the cluster using `kubectl`.
- **Install Helm**: Installs Helm, a package manager for Kubernetes.
- **Install KEDA**: Installs Kubernetes Event-Driven Autoscaling (KEDA) using Helm.
- **Create Deployment**: Deploys an application with event-driven scaling (e.g., based on CPU utilization or custom events).
- **Health Status Retrieval**: Fetches health and resource utilization metrics of deployments.

---

## 🛠️ Prerequisites

Before setting up the Kubernetes cluster, the following infrastructure was created using Terraform:

- **VPC**: Virtual Private Cloud.
- **Public and Private Subnets**: Subnets for various workloads.
- **S3 Buckets**: For Kops state storage and other purposes.
- **NAT Gateway**: Provides access to the internet for private subnets.
- **Routing Tables**: For controlling the traffic flow between subnets.
- **Internal Hosted Zones (Route 53)**: For DNS resolution inside the VPC.
- **Bastion Node**: Used for secure access to private nodes, provisioned using Terraform and bootstrapped with a custom `user-data.sh` script.

---

## ⚙️ Kubernetes Cluster Setup

Once the bastion node is ready, the Kubernetes cluster is configured using Kops with the provided `kops.yaml` configuration file.

Ensure the following before usage:

- Kubernetes Cluster is accessible via `kubectl`.
- Helm is either already installed or will be installed by the script.
- Metrics Server is installed for resource utilization metrics.

---

## 📦 Installation

```bash
# 1. Clone the repository
git clone https://github.com/VarunNagesh/simplismart.git
cd simplismart

# 2. Make the script executable
chmod +x keda-manager.sh
