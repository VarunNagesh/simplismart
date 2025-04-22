Kubernetes Event-Driven Autoscaler (KEDA) Manager
This script automates operations on a bare Kubernetes cluster, including connecting to the cluster, installing necessary tools (Helm, KEDA), deploying applications with event-driven scaling, and retrieving health status for deployments.

🚀 Features
Connect to the Kubernetes Cluster: Establish connection to the cluster using kubectl.

Install Helm: Installs Helm, a package manager for Kubernetes.

Install KEDA: Installs Kubernetes Event-Driven Autoscaling (KEDA) using Helm.

Create Deployment: Deploys an application with event-driven scaling (e.g., based on CPU utilization or custom events).

Health Status Retrieval: Fetches health and resource utilization metrics of deployments.

🛠️ Prerequisites
Before setting up the Kubernetes cluster, the following infrastructure was created using Terraform:

VPC: Virtual Private Cloud.

Public and Private Subnets: Subnets for various workloads.

S3 Buckets: For Kops state storage and other purposes.

NAT Gateway: Provides access to the internet for private subnets.

Routing Tables: For controlling the traffic flow between subnets.

Internal Hosted Zones (Route 53): For DNS resolution inside the VPC.

Bastion Node: Used for secure access to private nodes, provisioned using Terraform and bootstrapped with a custom user-data script (user-data.sh).

Kubernetes Cluster Setup
Once the bastion node is ready, the Kubernetes cluster is configured using Kops with the provided kops.yaml configuration file.

To ensure smooth operation, ensure the following:

Kubernetes Cluster: Accessible via kubectl.

Helm: Either already installed or will be installed by the script.

Metrics Server: Installed in the cluster for resource utilization metrics.

📦 Installation

1. Clone the repository
git clone https://github.com/VarunNagesh/simplismart.git
cd simplismart

2. Make the script executable
Ensure that the script is executable before running it.
chmod +x keda-manager.sh

📝 Usage
Command Syntax
./keda-manager.sh [--kubeconfig <path>] <command> [args]

Where:

--kubeconfig <path>: Optional flag to specify the path to the kubeconfig file (default: ~/.kube/config).

<command>: The operation you want to perform (e.g., install-helm, install-keda, deploy, health).

[args]: Arguments for the respective commands.

Available Commands
1. connect
Connect to the Kubernetes cluster and verify the connection.
./keda-manager.sh --kubeconfig ~/.kube/mycluster.yaml connect

2. install-helm
Install Helm, a package manager for Kubernetes.
./keda-manager.sh install-helm

3. install-keda
Install KEDA (Kubernetes Event-Driven Autoscaling) via Helm.
./keda-manager.sh install-keda

4. deploy <name> <image> <port>
Deploy a containerized application with event-driven scaling using KEDA. The parameters are:

<name>: The name of the deployment.

<image>: The Docker image to use for the deployment (e.g., nginx:latest).

<port>: The port the application will expose.

Example:
./keda-manager.sh deploy myapp nginx:latest 80

5. health <name>
Check the health and resource utilization of a deployment.

Example:
./keda-manager.sh health myapp

6. help
Show help and list all available commands.
./keda-manager.sh help

💡 Example Workflow
Connect to your Kubernetes cluster:
./keda-manager.sh --kubeconfig ~/.kube/mycluster.yaml connect

Install Helm:
./keda-manager.sh install-helm

Install KEDA:
./keda-manager.sh install-keda

Deploy an application with event-driven scaling:
./keda-manager.sh deploy myapp nginx:latest 80

Check health and metrics of the deployed application:
./keda-manager.sh health myapp

📋 Troubleshooting
No access to Kubernetes cluster: Ensure that your kubectl context is correctly configured to access the Kubernetes cluster. You can check the connection using:
kubectl cluster-info

Helm is not installed: The script will automatically install Helm if it’s not found. Ensure you have access to the internet to download Helm.

KEDA installation issues: If the Helm installation of KEDA fails, ensure that Helm repositories are up-to-date:

helm repo update
Health command errors: The kubectl top command requires the metrics-server to be installed in your cluster. If you don't have it, you can install it by following the Metrics Server installation guide.

🔧 Customization
Kubeconfig file: If your Kubernetes cluster uses a custom kubeconfig file, you can specify it using the --kubeconfig flag for each command.