#!/bin/bash

# ************************************************************************** */
# Increase disk size                                                         */
# ************************************************************************** */

lsblk
df -h /
sudo growpart /dev/vda 1
sudo resize2fs /dev/vda1
df -h /

# ************************************************************************** */
# Setup Docker Engine                                                        */
# ************************************************************************** */

# Source: official Docker documentation: https://docs.docker.com/engine/install/debian/

# Set up Docker's apt repository.
# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl zsh -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

# Install Docker packages
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Verify that Docker is running
#sudo systemctl status docker

# Verify that the installation is successful by running the hello-world image
sudo docker run hello-world

# ************************************************************************** */
# Setup Kubectl                                                              */
# ************************************************************************** */

# Source: official kubernetes documentation: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

# Download the latest release with the command:
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"

# Install kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# ************************************************************************** */
# Setup k3d                                                                  */
# ************************************************************************** */

# Install current latest release of k3d
# Source: official k3d documentation: https://k3d.io/stable/#installation
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Source: official k3d documentation: https://k3d.io/stable/#quick-start

# Create a cluster named mycluster with just a single server node for testing purposes
sudo k3d cluster create mycluster -p "8888:80@loadbalancer"

# Use the new cluster with kubectl, e.g.:
sudo kubectl get nodes

# Apply all configuration files
sudo kubectl create -f ./confs/00-namespaces.yaml

# Check that namespaces have been created
sudo kubectl get namespace

# Inspect Events inside dev namespace
sudo kubectl describe pod -l app=playground -n dev

# ************************************************************************** */
# Setup Helm                                                         */
# ************************************************************************** */

# Installing Helm From Apt (Debian/Ubuntu)
# Source: https://helm.sh/fr/docs/intro/install

sudo apt-get install gpg apt-transport-https --yes
curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

# Downloading official Gitlab repository
helm repo add gitlab https://charts.gitlab.io/

# Installing GitLab using Helm and Helm values
helm install gitlab gitlab/gitlab \
  --values ./confs/01-gitlab.yaml \
  --namespace gitlab

# Check that Gitlab pods are running
sudo kubectl get pods -n gitlab

# ************************************************************************** */
# Setup Argo CD                                                              */
# ************************************************************************** */

# Source: official Argo CD documentation: https://argo-cd.readthedocs.io/en/latest/
sudo kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Check that Argo CD pods are running
sudo kubectl get pods -n argocd

# Apply Argo CD configuration
sudo kubectl apply -f ./confs/02-argocd.yaml

# Apply Ingress configuration
sudo kubectl apply -f ./confs/03-ingress.yaml

# Check that Ingress is active
sudo kubectl get ingress -n dev

# Waiting for Argo CD server to be available
sudo kubectl wait --namespace argocd \
  --for=condition=available deployment/argocd-server \
  --timeout=90s

# Get admin password for Argo CD dashboard
sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

# Port forwarding to access Argo CD dashboard from host machine browser
#sudo kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8443:443