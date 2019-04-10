## Clone the lab repo
git clone https://github.com/nerdguru/devnet-create-faas-on-k8s.git

## Install kubectl with snap
sudo snap install kubectl --classic

## Set the approrpiate variable
export KUBECONFIG=~/devnet-create-faas-on-k8s/kubeconfig.yaml

## Install and init helm w upgrade
sudo snap install helm --classic
helm init --skip-refresh --upgrade

########################
## Wait for helm to init
########################

helm repo update

## Install Minio
helm install stable/minio --name fonkfe --set service.type=LoadBalancer,persistence.enabled=false

## Install Mongo
helm install stable/mongodb --name fonkdb --set service.type=LoadBalancer,persistence.enabled=false,usePassword=false


## Install OpenWhisk back end
git clone https://github.com/apache/incubator-openwhisk-deploy-kube.git
kubectl label nodes --all openwhisk-role=invoker
helm install incubator-openwhisk-deploy-kube/helm/openwhisk --namespace=openwhisk --name=owdev -f ~/devnet-create-faas-on-k8s/myOWcluster.yml

## Install and configure OpenWhisk CLI
wget https://github.com/apache/incubator-openwhisk-cli/releases/download/0.10.0-incubating/OpenWhisk_CLI-0.10.0-incubating-linux-386.tgz
tar -xf OpenWhisk_CLI-0.10.0-incubating-linux-386.tgz
sudo mv wsk /usr/local/bin

## Install Node and npm
sudo apt update
sudo apt-get install -y nodejs
sudo apt-get install -y npm

## Install Serverless
sudo npm install -g serverless
sudo node /usr/local/lib/node_modules/serverless/scripts/postinstall.js
sudo chown -R $USER:$(id -gn $USER) /home/ubuntu/.config

##################################################
## After all the OpenWhisk pods are up and Running
##################################################

## Configure wsk
wsk property set --apihost 10.10.20.208:31001
wsk property set --auth 23bc46b1-71f6-4ed5-8c54-816aa4f8c502:123zO3xZCLrMN6v2BKK1dXYFpXlPkccOFqm12CdAsMgRU4VrNZ9lyGVCGuMDGIwP
sudo apt install -y zip

wsk action create create --kind nodejs:6 create.zip -i

## Install Docker per https://docs.docker.com/install/linux/docker-ce/ubuntu/
sudo snap install docker

## Install OpenFaaS CLI
curl -sSL https://cli.openfaas.com | sudo sh

## Install OpenFaaS back end
kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml
helm repo add openfaas https://openfaas.github.io/faas-netes/
export PASSWORD=Cisco123

kubectl -n openfaas create secret generic basic-auth \
--from-literal=basic-auth-user=admin \
--from-literal=basic-auth-password="$PASSWORD"

helm repo update \
 && helm upgrade openfaas --install openfaas/openfaas \
    --namespace openfaas  \
    --set basic_auth=true \
    --set functionNamespace=openfaas-fn

export OPENFAAS_URL=http://10.10.20.208:31112

###################################
## After OpenFaaS is up and running
export PASSWORD=Cisco123
echo -n $PASSWORD | faas-cli login -g $OPENFAAS_URL -u admin --password-stdin
faas-cli version
