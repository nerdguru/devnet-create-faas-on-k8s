# run with "source dev-client.sh"

## Clone the lab repo
git clone https://github.com/nerdguru/devnet-create-faas-on-k8s.git

## Install kubectl with snap
sudo snap install kubectl --classic

## Set the approrpiate variable
export KUBECONFIG=~/devnet-create-faas-on-k8s/kubeconfig.yaml

## Install and init helm w upgrade
sudo snap install kubectl --classic
helm init --skip-refresh --upgrade

## Install Minio
helm install stable/minio --name fonkfe --set service.type=LoadBalancer,persistence.enabled=false

## Install Mongo
helm install stable/mongodb --name fonkdb --set service.type=LoadBalancer,persistence.enabled=false,usePassword=false
