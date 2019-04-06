# run with "source dev-client.sh"

## Clone the lab repo
git clone https://github.com/nerdguru/devnet-create-faas-on-k8s.git

## Install kubectl per https://kubernetes.io/docs/tasks/tools/install-kubectl/
sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

## Set the approrpiate variable
export KUBECONFIG=~/devnet-create-faas-on-k8s/kubeconfig.yaml
