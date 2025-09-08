# This script installs the kubectl and eksctl tools for managing Kubernetes clusters on AWS EKS.
#!/bin/bash

# Install kubectl
echo "Installing kubectl..."
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.0/2025-05-01/bin/linux/amd64/kubectl
if [ $? -ne 0 ]; then
    echo "Failed to download kubectl. Please check your internet connection or the URL."
    exit 1
fi
echo "Verifying kubectl checksum..."
openssl sha1 -sha256 kubectl
if [ $? -ne 0 ]; then
    echo "Failed to verify kubectl checksum. Please check the file integrity."
    exit 1
fi
echo "Making kubectl executable..."
chmod +x ./kubectl
if [ $? -ne 0 ]; then
    echo "Failed to make kubectl executable. Please check permissions."
    exit 1
fi
echo "Moving kubectl to /usr/local/bin..."
sudo mv ./kubectl /usr/local/bin
if [ $? -ne 0 ]; then
    echo "Failed to move kubectl to /usr/local/bin. Please check permissions."
    exit 1
fi
echo "kubectl installed successfully."
kubectl version

# Install eksctl
echo "Installing eksctl..."

ARCH=amd64

PLATFORM=$(uname -s)_$ARCH

curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
if [ $? -ne 0 ]; then
    echo "Failed to download or extract eksctl. Please check your internet connection or the URL."
    exit 1
fi
echo "Moving eksctl to /usr/local/bin..."
sudo mv /tmp/eksctl /usr/local/bin
if [ $? -ne 0 ]; then
    echo "Failed to move eksctl to /usr/local/bin. Please check permissions."
    exit 1
fi
echo "eksctl installed successfully."
eksctl version
echo "Installation of kubectl and eksctl completed successfully."

# Install Matrix server for Horizontal Pod Autoscaler in k8s
echo "Installing Horizontal Pod Autoscaler..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml


# Install k9s
echo "Installing k9s..."
curl -sS https://webinstall.dev/k9s | bash
if [ $? -ne 0 ]; then
    echo "Failed to install k9s. Please check your internet connection or the URL."
    exit 1
fi
echo "k9s installed successfully."

# Install Helm
echo "Installing Helm..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
if [ $? -ne 0 ]; then
    echo "Failed to install Helm. Please check your internet connection or the URL."
    exit 1
fi
echo "Helm installed successfully."

# Install ebs-csi-driver
echo "Installing EBS CSI Driver..."
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update
helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver --namespace kube-system
if [ $? -ne 0 ]; then
    echo "Failed to install EBS CSI Driver. Please check your internet connection or the Helm repository."
    exit 1
fi
echo "EBS CSI Driver installed successfully."

# verify installations
echo "Verifying installations..."
kubectl version --short
eksctl version
k9s version
helm version
kubectl get pods -n kube-system
if [ $? -ne 0 ]; then
    echo "Failed to verify Kubernetes cluster. Please check your kubectl configuration."
    exit 1
fi
echo "All installations verified successfully."