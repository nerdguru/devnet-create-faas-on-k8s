# OpenFaaS FONK Guestbook (Node.js)

This folder contains a version of the FONK Guestbook application written in Node.js using OpenFaas.  The steps are as follows:

* Creating `create.yml` and `list.yml`
* Building, Pushing, and Deploying the functions
* Testing your API with `curl`
* Deploying your Web UI

## Creating `create.yml` and `list.yml`
In OpenFaaS, functions are defined using a .yml file format that describes where the OpenFaaS instance being used is located, where the function binary resides, and where the container image used to implement the function can be found.

In this folder, there are two templates for the two back-end Guestbook functions, `create.template` and `list.template`.  The first step is to edit each of these and save them as their .yml variants.  To do this, the master IP address of the Kubernets cluster running OpenFaaS is needed, as is the username being used for the container image repo configured on your Docker command line.

## Building, Pushing, and Deploying the functions
OpenFaaS pulls container images from a repo at deployment time, after those images have been built and pushed to that repo.  While OpenFaaS hides the subsequent `Dockerfile` from the developer in its templating system, a local copy of Docker configured to talk to the repo in question is required before proceeding.

With those prerequisites in place, and keeping in mind that Docker often requires `sudo` access, here are the three commands needed to build, push, and deploy a function to OpenFaas.  First, build the container image that houses the function.

```bash
$ sudo faas-cli build -f create.yml
[0] > Building list.
Clearing temporary build folder: ./build/create/
Preparing ./create/ ./build/create/function
Building: <username>/create with node8-express template. Please wait..
Sending build context to Docker daemon  11.78kB
Step 1/26 : FROM node:8.9.4-alpine
 ---> 406f227b21f5
Step 2/26 : RUN addgroup -S app && adduser -S -g app app
 ---> Using cache
 ---> 9a33015af0b1
.
.
.
Step 26/26 : CMD ["fwatchdog"]
 ---> Running in 8504327b4e77
Removing intermediate container 8504327b4e77
 ---> d8c3cf003d6d
Successfully built d8c3cf003d6d
Successfully tagged <username>/create:latest
Image: <username>/create built.
[0] < Building create done.
[0] worker done.
```

Next, push that image to the repo (requires a DockerHub account and being logged in via the docker CLI):
```bash
$ sudo faas-cli push -f create.yml
[0] > Pushing create.
The push refers to repository [docker.io/<username>/create]
b5f158794b91: Pushed
6293e4114d0e: Pushed
.
.
.
latest: digest: sha256:4fa962fa09d0d6e05190e006c94fc7c1e4d0f5f3eec1dbc0c7dfce2a13005396 size: 3038
[0] < Pushing create done.
[0] worker done.
```

Finally, deploy the image to the OpenFaaS instance:
```bash
$ sudo faas-cli deploy -f create.yml
Deploying: create.

Deployed. 202 Accepted.
URL: http://10.10.20.208:31112/function/create
```

Rinse and repeat for `list`:

```bash
$ sudo faas-cli build -f list.yml
$ sudo faas-cli push -f list.yml
$ sudo faas-cli deploy -f list.yml
```

## Testing your API with `curl`
Among the information the `deploy` command returns with is the URL that can be used to invoke the function with `curl`.  So using the examples above `create` looks like this:

```bash
$ curl -X POST --header "Content-Type:application/json" -d '{"text":"Hello Again"}'  http://10.10.20.208:31112/function/create
{
  "updatedAt":1536263964550,
  "text":"Hello Again",
  "_id":"5b91871cc2cbee00084dd16f"
}
```

and `list`:

```bash
$ curl http://10.10.20.208:31112/function/list
{
  "entries":[{
    "_id":"5b9183737c17c7000a6e1aca",
    "updatedAt":1536263027935,
    "text":"Hello World"},
    {"_id":"5b91871cc2cbee00084dd16f",
    "updatedAt":1536263964550,
    "text":"Hello Again"}]
}
```

These two URLs can now be used on the `frontend`, although note in the source code of the functions that the OpenFaaS API gateway does not return `Access-Control-Allow-Origin: *` by default, hence why that is set explicitly by each function to avoid CORS issues with the GUI.

## Deploying your Web UI
