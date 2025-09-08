#!/bin/bash
set -euo pipefail

echo "==============================="
echo "Installing kubectl, eksctl, k9s, helm, metrics-server, and EBS CSI driver on RHEL"
echo "==============================="

# Step 0: Install prerequisites for RHEL
echo "[0/7] Installing prerequisites..."
sudo yum install -y curl tar coreutils
echo "Prerequisites installed."

# Install kubectl
echo "[1/7] Installing kubectl..."
KUBECTL_VERSION=$(curl -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
echo "Verifying kubectl checksum..."
curl -LO "https://dl.k8s.io/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
chmod +x kubectl
sudo mv kubectl /usr/local/bin
rm kubectl.sha256
kubectl version --client --short
echo "kubectl installed successfully."

# Install eksctl
echo "[2/7] Installing eksctl..."
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_${PLATFORM}.tar.gz"
tar -xzf eksctl_${PLATFORM}.tar.gz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
rm eksctl_${PLATFORM}.tar.gz
eksctl version
echo "eksctl installed successfully."

# Install Helm
echo "[3/7] Installing Helm..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm get_helm.sh
helm version
echo "Helm installed successfully."

# Install k9s
echo "[4/7] Installing k9s..."
K9S_URL=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest \
    | grep "browser_download_url.*Linux_x86_64.tar.gz" \
    | cut -d '"' -f 4)
curl -LO "$K9S_URL"
tar -xzf k9s_Linux_x86_64.tar.gz -C /tmp
sudo mv /tmp/k9s /usr/local/bin
rm k9s_Linux_x86_64.tar.gz
k9s version
echo "k9s installed successfully."

# Check if cluster is available
if kubectl version --short &>/dev/null; then
    echo "[5/7] Installing metrics-server..."
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    echo "metrics-server installed successfully."

    echo "[6/7] Installing AWS EBS CSI Driver..."
    helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
    helm repo update
    helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver --namespace kube-system
    echo "AWS EBS CSI Driver installed successfully."
else
    echo "⚠ No Kubernetes cluster detected. Skipping metrics-server and EBS CSI driver installation."
fi

# Verification
echo "[7/7] Verifying installations..."
kubectl version --short || echo "kubectl installed, but cluster not connected."
eksctl version
k9s version
helm version
if kubectl get pods -n kube-system &>/dev/null; then
    kubectl get pods -n kube-system
fi

echo "==============================="
echo "All tools installed and verified successfully!"
echo "==============================="
# #!/bin/bash
# echo "Installing kubectl..."
# curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.0/2025-05-01/bin/linux/amd64/kubectl
# if [ $? -ne 0 ]; then
#     echo "Failed to download kubectl. Please check your internet connection or the URL."
#     exit 1
# fi
# echo "Verifying kubectl checksum..."
# openssl sha1 -sha256 kubectl
# if [ $? -ne 0 ]; then
#     echo "Failed to verify kubectl checksum. Please check the file integrity."
#     exit 1
# fi
# echo "Making kubectl executable..."
# chmod +x ./kubectl
# if [ $? -ne 0 ]; then
#     echo "Failed to make kubectl executable. Please check permissions."
#     exit 1
# fi
# echo "Moving kubectl to /usr/local/bin..."
# sudo mv ./kubectl /usr/local/bin
# if [ $? -ne 0 ]; then
#     echo "Failed to move kubectl to /usr/local/bin. Please check permissions."
#     exit 1
# fi
# echo "kubectl installed successfully."


# # Install eksctl
# echo "Installing eksctl..."

# ARCH=amd64

# PLATFORM=$(uname -s)_$ARCH

# curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
# tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
# if [ $? -ne 0 ]; then
#     echo "Failed to download or extract eksctl. Please check your internet connection or the URL."
#     exit 1
# fi
# echo "Moving eksctl to /usr/local/bin..."
# sudo mv /tmp/eksctl /usr/local/bin
# if [ $? -ne 0 ]; then
#     echo "Failed to move eksctl to /usr/local/bin. Please check permissions."
#     exit 1
# fi
# echo "eksctl installed successfully."
# echo "Installation of kubectl and eksctl completed successfully."

# # Install ebs-csi-driver
# echo "Installing EBS CSI Driver..."
# helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
# helm repo update
# helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver --namespace kube-system

# # Install Matrix server for Horizontal Pod Autoscaler in k8s
# kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# # Install k9s
# echo "Installing k9s..."
# curl -sS https://webinstall.dev/k9s | bash

# # Install Helm
# echo "Installing Helm..."
# curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
# chmod 700 get_helm.sh
# ./get_helm.sh

# # verify installations
# echo "Verifying installations..."
# kubectl version --short
# eksctl version
# k9s version
# helm version
# kubectl get pods -n kube-system
# echo "All installations verified successfully."