# OpenWhisk FONK Guestbook (Node.js)

This folder contains a version of the FONK Guestbook application written in Node.js using OpenWhisk. The steps to getting it running are as follows:

* Your `serverless.yml`
* Deploying the functions
* Testing your API with `curl`
* Looking at your containers
* Deploying your Web UI

## Your `serverless.yml`
In order to simplify packaging for deployment, the [Serverless Framework](http://serverless.com) is used to deploy your functions onto OpenWhisk.  

OpenWhisk executes functions in such a way that they do not have any Kubernetes (aka k8s) context and therefore cannot take advantage of k8s naming conventions when accessing microservices running in other parts of the cluster, such as the MongoDB being used to store Guestbook data.  `fonkdb-mongodb.default:27017` will not work since that assumes k8s context, so the information about the Mongo host needs to be passed in another way.

OpenWhisk does not support environment variables, per se, but it does support default parameters, which can be set in the `serverless.yml` file. If you look at the code in either of our functions, found in `./create.js` or `./list.js` notice how the MongoDB connection is made:

```js
var url = 'mongodb://' + params.mongoHost + '/guestbook_app';

MongoClient.connect(url, (err, db) => {
  .
  .
  .
});
```

In this case, when deploying the functions a default parameter named `mongoHost` needs to be set in `serverless.yml` to a MongoDB host string that will enable each function to connect to MongoDB without using k8s naming conventions.

The default MongoDB host string has already been set in 'serverless.yml' but to discover what to set `mongoHost` should be, start with:

```bash
$ kubectl get services
NAME              TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)           AGE
fonkdb-mongodb   LoadBalancer   10.105.107.36   <pending>     27017:31073/TCP   32m
```

When MongoDB was deployed, it was configured to utilize a `LoadBalancer` so that a host string could be constructed.  There are two ways to create the host string and your mileage may vary on each path depending up on the external IP address capabilities of your k8s cluster.

In this example, the `CLUSTER-IP` is showing a private IP address and a pending `EXTERNAL-IP` address for what is likely a cluster not capable of generating an `EXTERNAL-IP`.

If your cluster is capable of generating an `EXTERNAL-IP` and it is shown when executing the command above, your host string is simply `<EXTERNAL-IP>:27017`.

If your cluster is not capable of generating an `EXTERNAL-IP`, see what port Mongo is mapped to (`31073` in the example above) and use `kubectl cluster-info` to find your cluster master IP address.  The host string is then `<cluster master IP>:<mapped port>`.

## Deploying the functions
With the `serverless.yml` saved, the function dependencies can be installed and then the functions deployed using:

```bash
npm install
serverless deploy -v
```

With the functions now deployed on OpenWhisk, they can can be invoked using the `wsk` command line:

```bash
$ wsk action invoke create --param text 'Hello World' -i --result
{"text":"Hello World","id":"96c40bf0-9fce-11e8-bae7-c9e603322f7a","updatedAt":1534257027631,"_id":"5b72e783b7e86e82fc592440"}

$ wsk action invoke list -i --result
[{"_id":"5b72e783b7e86e82fc592440","text":"Hello World","id":"96c40bf0-9fce-11e8-bae7-c9e603322f7a","updatedAt":1534257027631}]
```

But what about interacting with the functions through an API endpoint?  

## Testing your API with `curl`
Because functions were created with the `--web true` switch, they are now reachable with `curl`:

```bash
$ curl -X POST --header "Content-Type:application/json" -d '{"text":"Hello Again"}' --insecure https://10.10.20.208:31001/api/v1/web/guest/default/guestbook-dev-create.json
{
  "text": "Hello Again",
  "id": "05cfd6b0-a23a-11e8-86ec-8f9a22b282bf",
  "updatedAt": 1534523072411,
  "_id": "5b76f6c060ae0a00072bc655"
}

$ curl --insecure https://10.10.20.208:31001/api/v1/web/guest/default/guestbook-dev-list.json
{
  "entries": [{
    "_id": "5b76ec2ad6827500052378f4",
    "text": "Hello World",
    "id": "b66208b0-a233-11e8-b878-ffe412a8988f",
    "updatedAt": 1534520362171
  }, {
    "_id": "5b76ef74d45b63000577a142",
    "text": "Hello Again",
    "id": "ac7a9040-a235-11e8-8e4a-635e3a97c9a7",
    "updatedAt": 1534521204548
  }]
}

```

## Looking at your containers
You can take a look at what containers OpenWhisk mantains through `kubectl`:
```
$ kubectl get pods -n openwhisk
NAME                                      READY   STATUS      RESTARTS   AGE
owdev-alarmprovider-d84786b95-8ltbj       1/1     Running     0          5h
owdev-apigateway-59b867d57-q7jz6          1/1     Running     0          5h
owdev-cloudantprovider-69f966579d-j27g4   1/1     Running     0          5h
owdev-controller-0                        1/1     Running     0          5h
owdev-couchdb-7dd9cbbbd7-qpkph            1/1     Running     0          5h
owdev-init-couchdb-jsvv5                  0/1     Completed   0          5h
owdev-install-packages-q6474              0/1     Running       0          5h
owdev-install-packages-zr548              0/1     Running       0          5h
owdev-invoker-bgbs8                       1/1     Running     0          5h
owdev-invoker-lrqdh                       1/1     Running     0          5h
owdev-kafka-0                             1/1     Running     0          5h
owdev-kafkaprovider-5b9d6c5c5b-t9fn9      1/1     Running     0          5h
owdev-nginx-79dcc64c7d-v9q8t              1/1     Running     0          5h
owdev-redis-74d5d5f6bb-kx7gd              1/1     Running     0          5h
owdev-wskadmin                            1/1     Running     0          5h
owdev-zookeeper-0                         1/1     Running     0          5h
```
Note that there are no persistent containers to run the functions and that this set of containers will remain roughly the same as OpenWhisk scales to more functions.

## Deploying your Web UI
The FONK Guestbook Front End setup steps are as follows:

* Accessing the Minio UI & Creating a Public Bucket
* Setting Your API Endpoints
* Bypassing the SSL Certificate
* Deploying & Testing Your Front End

### Accessing the Minio UI & Creating a Public Bucket
There are two ways to interact with the Minio GUI and your mileage may vary on each path depending up on the external IP address capabilities of your K8S cluster.  Start with:

```bash
$ kubectl get services
NAME              TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)           AGE
fonkfe-minio      LoadBalancer   10.102.57.24    <pending>     9000:30126/TCP    18m
```

In this example, the `CLUSTER-IP` is showing a private IP address and a pending `EXTERNAL-IP` address for what is likely a cluster not capable of generating an `EXTERNAL-IP`.

If your cluster is capable of generating an `EXTERNAL-IP`, point a browser to simply `http://<your IP>:9000/`.

If your cluster is not capable of generating an `EXTERNAL-IP`, see what port Minio is mapped to and point a browser to `http://<cluster master IP>:<mapped port>/`.  In the example above, where the master IP (not shown above, but determined with `kubecltl cluster-info`) that would evaluate to `http://< cluster master IP>:30126`.

Regardless of which method you use to engage the Minio GUI, you will be prompted to provide a Access Key and Secret Key.  The default Access Key is `AKIAIOSFODNN7EXAMPLE` and default Secret Key is `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`.  After logging in you should see something similar to:

![Minio UI](minio-ui.jpg)

Click on the big red + sign and create a bucket named `guestbook`.  Once that is created, hover over the bucket name in the left side bar to reveal three vertical dots:

![guestbook bucket](guestbook-bucket.jpg)

Click on the three dots and select `Edit Policy`.  Add a new policy that has a Prefix of `*` and Read Only:

![bucket policy](bucket-policy.jpg)

This will enable you to point to `http://<your ip>:9000/guestbook/openfaas-index.html` from a browser in later steps.

### Setting Your API Endpoints
In `openfaas-rest.js`, the first two lines read as:

```js
createPath = 'https://10.10.20.208:31001/api/v1/web/guest/default/guestbook-dev-create.json'; // Path to create API endpoint
listPath = 'https://10.10.20.208:31001/api/v1/web/guest/default/guestbook-dev-list.json'; // Path to list API endpoint
```

As the comment suggests, place the URL path to the `create` and `list` API endpoints, although this might already be set for you.

### Bypassing the SSL Certificate
OpenWhisk ships with a self-signed certificate and requires HTTPS, which by default the code in the front end will not work correctly because every browser in the world will by default require signed certificates.

To work around this, the URL for the functions can be entered in the browser you will use to conduct run the front end.  Something like:

```bash
https://10.10.20.208:31001/api/v1/web/guest/default/guestbook-dev-list.json
```

### Deploying & Testing Your Front End
With the `guestbook` bucket selected in the Minio UI, click on the big red + sign and upload both `openwhisk-index.html` and your newly edited `openwhisk-rest.js`.

Point a fresh browser tab to `http://<your ip>:9000/guestbook/openwhisk-index.html` and interact with the Guestbook.

![guestbook ui](guestbook-ui.jpg)

Note that, depending upon a variety of performance factors, as messages are added from the GUI the MongoDB write may not happen quickly enough for the subsequent GUI read to catch up with it.  As such, refreshing the browser to get a fresh pull of the recently written data may be needed.
