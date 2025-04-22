#!/bin/bash
# Install git, postgresql, and unzip
sudo apt update && sudo apt install -y git postgresql unzip

# Install Ansible
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt update
sudo apt install -y ansible

# Install kubectl
curl -LO "https://dl.k8s.io/release/v1.25.5/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install kops
curl -Lo kops https://github.com/kubernetes/kops/releases/download/v1.29.0/kops-linux-amd64
chmod +x kops
sudo mv kops /usr/local/bin/kops

# Install aws-cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install istioctl
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.16.1 TARGET_ARCH=x86_64 sh -
sudo mv istio-1.16.1/bin/istioctl /usr/bin/
istioctl version

sudo gpg -k
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt-get update
sudo apt-get install k6

cd /home/ubuntu

sudo apt update
wget https://dlcdn.apache.org/kafka/3.8.0/kafka_2.13-3.8.0.tgz
tar -xzf kafka_2.13-3.8.0.tgz
sudo apt install default-jre -y