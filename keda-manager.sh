#!/bin/bash

set -e

# ------------------------------
# Default Values
# ------------------------------
KUBECONFIG_PATH="$HOME/.kube/config"
NAMESPACE="keda"
HELM_RELEASE_NAME="keda"

# ------------------------------
# Parse Arguments
# ------------------------------
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        --kubeconfig)
            KUBECONFIG_PATH="$2"
            shift 2
            ;;
        -*|--*)
            echo "❌ Unknown option $1"
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

# Restore positional parameters
set -- "${POSITIONAL_ARGS[@]}"

# Set kubeconfig globally for kubectl and helm
export KUBECONFIG="$KUBECONFIG_PATH"

# ------------------------------
# Function: Connect to Cluster
# ------------------------------
connect_to_cluster() {
    echo "🔌 Connecting using kubeconfig: $KUBECONFIG"
    
    if kubectl cluster-info; then
        echo "✅ Cluster connection successful"
        kubectl get nodes
    else
        echo "❌ Failed to connect to cluster"
        exit 1
    fi
}

# ------------------------------
# Function: Install Helm
# ------------------------------
install_helm() {
    if ! command -v helm &>/dev/null; then
        echo "📦 Installing Helm..."
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    fi
    echo "✅ Helm installed: $(helm version --short)"
}

# ------------------------------
# Function: Install KEDA
# ------------------------------
install_keda() {
    echo "📦 Installing KEDA via Helm..."
    helm repo add kedacore https://kedacore.github.io/charts
    helm repo update

    helm upgrade --install "$HELM_RELEASE_NAME" kedacore/keda \
        --namespace "$NAMESPACE" --create-namespace

    echo "⏳ Waiting for KEDA to be ready..."
    kubectl rollout status deployment/keda-operator -n "$NAMESPACE"
    echo "✅ KEDA ready in namespace '$NAMESPACE'"
}

# ------------------------------
# Function: Create Deployment
# ------------------------------
create_deployment_with_autoscaler() {
    DEPLOYMENT_NAME=$1
    IMAGE_NAME=$2
    PORT=$3

    if [[ -z "$DEPLOYMENT_NAME" || -z "$IMAGE_NAME" || -z "$PORT" ]]; then
        echo "Usage: deploy <deployment-name> <image:tag> <port>"
        exit 1
    fi

    kubectl create namespace "$DEPLOYMENT_NAME" --dry-run=client -o yaml | kubectl apply -f -

    cat <<EOF | kubectl apply -n "$DEPLOYMENT_NAME" -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $DEPLOYMENT_NAME
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $DEPLOYMENT_NAME
  template:
    metadata:
      labels:
        app: $DEPLOYMENT_NAME
    spec:
      containers:
      - name: app
        image: $IMAGE_NAME
        ports:
        - containerPort: $PORT
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "250m"
            memory: "256Mi"
EOF

    cat <<EOF | kubectl apply -n "$DEPLOYMENT_NAME" -f -
apiVersion: v1
kind: Service
metadata:
  name: $DEPLOYMENT_NAME
spec:
  selector:
    app: $DEPLOYMENT_NAME
  ports:
    - protocol: TCP
      port: 80
      targetPort: $PORT
  type: ClusterIP
EOF

    cat <<EOF | kubectl apply -n "$DEPLOYMENT_NAME" -f -
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: $DEPLOYMENT_NAME-scaler
spec:
  scaleTargetRef:
    name: $DEPLOYMENT_NAME
  minReplicaCount: 1
  maxReplicaCount: 5
  triggers:
  - type: cpu
    metadata:
      type: Utilization
      value: "50"
EOF

    echo "✅ Deployment $DEPLOYMENT_NAME with KEDA autoscaler created"
}

# ------------------------------
# Function: Get Deployment Health
# ------------------------------
get_deployment_health_status() {
    DEPLOYMENT_NAME=$1

    if [[ -z "$DEPLOYMENT_NAME" ]]; then
        echo "Usage: health <deployment-name>"
        exit 1
    fi

    echo "🔍 Health for $DEPLOYMENT_NAME"
    kubectl get deployment "$DEPLOYMENT_NAME" -n "$DEPLOYMENT_NAME" -o wide
    kubectl get pods -n "$DEPLOYMENT_NAME"
    kubectl top pods -n "$DEPLOYMENT_NAME" || echo "⚠️ metrics-server not installed"
}

# ------------------------------
# Function: Help
# ------------------------------
print_help() {
    cat <<EOF
Usage: $0 [--kubeconfig <path>] <command> [args]

Options:
  --kubeconfig <path>    Specify kubeconfig file (default: ~/.kube/config)

Commands:
  connect                         Connect to Kubernetes cluster
  install-helm                    Install Helm
  install-keda                    Install KEDA via Helm
  deploy <name> <image> <port>   Create deployment + autoscaler
  health <name>                  Check health and metrics
  help                            Show help

Examples:
  $0 --kubeconfig ~/.kube/mycluster.yaml connect
  $0 install-helm
  $0 install-keda
  $0 deploy myapp nginx:latest 80
  $0 health myapp
EOF
}

# ------------------------------
# Command Dispatcher
# ------------------------------
COMMAND="$1"; shift || true

case "$COMMAND" in
    connect) connect_to_cluster ;;
    install-helm) install_helm ;;
    install-keda) install_keda ;;
    deploy) create_deployment_with_autoscaler "$@" ;;
    health) get_deployment_health_status "$@" ;;
    help | *) print_help ;;
esac
