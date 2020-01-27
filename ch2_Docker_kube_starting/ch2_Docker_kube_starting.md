# First steps with Docker and Kubernetes

- This chapter covers:
  - Creating, running and sharing a container image with Docker
  - Running a single-node Kubernetes cluster locally
  - Setting up a Kubernetes cluster on Google Kubernetes Engine
  - Setting up and using the `kubectl` command-line client
  - Deploying an app on Kubernetes and scaling it horisontally

## 2.1 Creating, Running and Sharing a Container Image

- The next few sections cover:
  1. Installing docker
  2. Creating a trivial Node.js app that you'll later deploy to Kubernetes
  3. Package the app into a container image so you can then run it as an isolated container.
  4. Run a container based on the image
  5. Push the image to Docker Hub so that anyone anywher can run it.

### 2.1.1 Installing Docker and Running a Hello World Container

- Digital ocean has a good docker install tutorial

#### Running a Hello World Container

- Docker's hello world is run with:

```sh
$ docker run busybox echo "Hello world"
```

- This runs a busybox container (a container with busy box as its base OS) and tells it to print out `Hello world`.
- The important thing about hello world here is that it could have been a complex application, not just hello world.

#### Understanding What Happends behind the Scenes

- Docker pulled busybox from docker.io and ran `echo "hello world"` on it.

#### Running other Images

- Generally, docker images are run like `docker run <image>`, without specifying a command after the image name.

#### Versioning Container Images

- To run a specific version of an image use `docker run <image>:<tag>`

### 2.1.2 Creating a Trivial Node.js App

- To test kubernetes, we're building [app.js](./node_app/app.js), a simple web app that accepts HTTP requests, logs the incoming IP address and responds with its hostname.
  - This demonstrates how kubernetes handles hostnames. Note, this name is different from the http HOST header sent by the client.
  - This is exercise is useful for scaling out. You'll see requests hitting different replicas.

### 2.1.3 Creating a Dockerfile for the Image

- To test kubernetes, we're building a [Dockerfile](./node_app/Dockerfile) that runs app.js

### 2.1.4 Building the Container Image

- Before we run the app as a container, we must build an image (named `kubia`) from the Dockerfile.

```sh
$ cd ./node_app
$ docker build -t kubia .
```

#### Understanding How an Image is Built

- 