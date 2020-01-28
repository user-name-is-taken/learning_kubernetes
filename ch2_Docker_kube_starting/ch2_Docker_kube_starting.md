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

- The docker client tells the docker daemon builds the image. The docker daemon then pulls all the related files and builds the image. Note, these components don't have to be on the same computer. This is how tools like `docker-machine` work.

#### Understanding Image Layers

- Each docker image layer corresponds to a docker file command. Docker downloads each of these layers individually (unless the layer is stored locally).
- The last layer of an image is tagged. For example, in our example Dockerfile, the last layer is tagged as `kubia:latest`
- You can ess all images using `docker images` or `docker image ls`

#### Comparing Building IMages with a Dockerfile vs Manually

- An alternative to creating a docker file is to create a docker container, run commands in it, then build an image from the container's final state. This is bad practice. Using a Dockfile is essentially the same thing, but it's automatic, repeatable and you can source control it.

### 2.1.5 Running the Container Image

- 