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

## Install Node and npm
sudo apt-get install -y nodejs
sudo apt install -y npm

## Install Serverless
sudo npm install -g serverless

## Install OpenWhisk back end
git clone https://github.com/apache/incubator-openwhisk-deploy-kube.git
kubectl label nodes --all openwhisk-role=invoker
helm install ~/incubator-openwhisk-deploy-kube/helm/openwhisk --namespace=openwhisk --name=owdev -f ~/devnet-create-faas-on-k8s/myOWcluster.yaml

## Install and configure OpenWhisk CLI
wget https://github.com/apache/incubator-openwhisk-cli/releases/download/0.10.0-incubating/OpenWhisk_CLI-0.10.0-incubating-linux-386.tgz
tar -xf OpenWhisk_CLI-0.10.0-incubating-linux-386.tgz
sudo mv wsk /usr/local/bin
wsk property set --apihost 10.10.20.208:31001
wsk property set --auth 23bc46b1-71f6-4ed5-8c54-816aa4f8c502:123zO3xZCLrMN6v2BKK1dXYFpXlPkccOFqm12CdAsMgRU4VrNZ9lyGVCGuMDGIwP

## Install Docker per https://docs.docker.com/install/linux/docker-ce/ubuntu/
sudo snap install docker

## Install OpenFaaS back end
kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml
git clone https://github.com/openfaas/faas-netes.git
cd faas-netes/chart/openfaas
helm install . --namespace openfaas --set functionNamespace=openfaas-fn
cd

## Install OpenFaaS CLI
curl -sSL https://cli.openfaas.com | sudo sh
