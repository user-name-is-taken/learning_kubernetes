# Intro

- I installed kubernetes according to [this tutorial](https://tutorials.ubuntu.com/tutorial/install-a-local-kubernetes-with-microk8s#4)

- This chapter covers:
  - Using containers to isolate apps and reduce environmental differences
  - How kubernetes uses containers and docker
  - How kubernetes has changed development and deployment

- __Monolith__: a single process (or a small number of processes) running on a few managed servers.
  - causes slow release cycles
  - generally monoliths are developed and deployed separately.
  - When failures happen, the monolith is migrated to another server.

- __Microservice__: many decoupled (independent) processes runing on many servers.
  - each microservice is deployed, developed, updated and scaled individually
  - enables quick release cycles
  - Makes manually managing servers impossible. You need to automate server management.

- Automated server management includes:
  - scheduling microservices' resource utalization
  - automatic configuration
  - supervision
  - failure-handling

- Kubernetes automates servier management by:
  - allowing developers to deploy their own code.
  - allowing ops to easily monitor and reschedule failing apps. This allows them to focus on the infrastructure, not individual services.
  - abstracting hardware into a single resource

## 1.1 Understanding the need for a system like Kubernetes

- This section covers how microservices and new infrastructure have changed dev and ops and why kubernetes and docker are useful.

### 1.1.1 Moving from Monolithic apps to Microservices

- Monoliths run as a single OS process.
- Changes to monoliths require re-deploying it.

- 2 kinds of Scaling
  1. __Scaling up__: Buying more powerful hardware with enough resources for running an application.
    - This is expensive.
    - There's a hardware vertical limit on scaling.
  2. __Scaling out__: setting up additional servers and running multiple copies (replicas) of an application.
    - This is generally cheap.
    - There's no hardware horizontal limit on scaling.
    - For monoliths this generally requires changes to the application code to scale out.
    - Certain parts of an application are difficult to scale out, like the database.

- If any part of an application isn't scalable, the whole application isn't scalabel, unless you can split up the application.

#### Splitting Apps into Microservices

- Microservices run in their own processes and communicate over REST APIs or other async protocols like AMQP
  - REST = REpresentational State Transfer
  - AMQP = Advanced Message Queueing Protocol

- Microservices come with the advantage that they can be written in different languages that the microservices they communicate with.

#### Scaling Microservices

- Microservices scale independently of each other.
- Microservices can scale out onto mulitple servers.

#### Deploying Microservices

- Deployment challenges of having many microservices:
  - Inter-dependencies
    - Microservices are deployed on different machines, but not independently. Often, microservices rely on each other.
  - Where to deploy each microservice
  - How to fix a microservice if it goes down.
    - You may even be debugging across multiple microservices.
    - Distributed tracing systems like zipkin help with this.

#### Understanding the Divergence of Environment Requirements

- Microservice's dependencies often conflict (see python 2 vs 3). This makes installing them on the same machine difficult.

### 1.1.2 Providing a Consistent Environment to Applications

- Development and operations environment's libraries, hardware... are very different.
- Environments change over time.

- Ideally;
  - You can run the same environment for an application (OS, libraries, system configuration, networking...) during development and production and over time.
  - Applications' environments don't interfere with each other.

### 1.1.3 Moving to Continuous Delivery: DevOps and NoOps

- __DevOps__: where developers assist in operations and QA.

#### Understanding the Benefits

- DevOps provides devs and understanding of:
  - Op's issues
  - User's issues, feedback and needs
  - How to deploy quickly (making release cycles faster)

- Although DevOps is good, there should still be people focused on dev and others focused on ops. The two fields require different knowledge sets and skils.

#### Letting Developers and Sysadmins Do What They Do Best

- Developers want to make features for users
- Ops what to make features for developers, secure systems, utilization etc.

- In an ideal __NoOps__ environment, dev and ops are independent.
  - Developers can deploy their applications themselves
  - Operations staff can manage their hardware without worrying about the applications deployed.

- Kubernetes provides *NoOps* by abstracting away the actual hardware and exposing it as a single platform for deploying and running applications.

## 1.2 Understanding What Containers are

- Kubernetes solves the problems discussed in 1.1 by isolating apps inside containers.
  - Container technologies include *Docker* and *rkt*

### 1.2.1 Understanding What Containers are

- Both containers and VMs prevent dependency conflicts, but only containers:
  - Can be configured automatically
  - Share the host's OS (kernel), thereby saving resources, money and time in boots etc

#### Isolating Components with Linux Container Technologies

- Containers share the host's OS, but containers' processes are isolated from each other, preventing interference.

#### Comparing Virtual Machines to Containers

- While containers share the host's OS and resources, VMs don't. 
  - Each guest VM includes its own OS which translates instructions through the hypervisor to the host's OS.
  - Each guest VM stakes a claim on the host's resources (CPU, RAM, HHD...) through the hypervisor that other VM's can't use.

- Note, there are 2 types of hypervisors:
  - Type 1 hypervisor that don't use the host's OS
  - Type 2 hypervisor that does use the host's OS

- Because VM's overhead, Ops often group multiple apps on each VM instead of dedicating a whole VM to each app.
  - Containers don't have this overhead so apps are split into microservices

- VM's aren't all bad. VMs provide full OS isolation, while containers don't, but this comes at a large cost.

#### Introducing the Mechanisms that make Container Isolation Possible

- Containers isolate processes with 2 techniques:
  1. *Linux Namespaces* which give each process its own view of the system's files, processes, network interfaces, hostname...
  2. *Linux control groups* (aka *cgroups*) which limit the amount of resources the process can consume (CPU, memory, bandwidth...)

##### Isolating Processes with Linux Namespace

- A linux process belongs to one of each of the following categories of namespaces:
  - __Mount (mnt)__: 
  - __Process ID (pid)__: 
  - __Network (net)__: the network namespace determines which network interfaces the application running inside the process sees.
    - Network interfaces can only belong to 1 net interface.
    - Each container uses its own net namespace and has its own network interface.
  - __Inter-process communication (ipc)__: 
  - __UTS__: determines what hostname and domain name the process running inside the namespace sees
  - __User ID (user)__: 

- You can create custom namespaces to organize and isolate resources.

##### Limiting Resources Available to a Process

- *Cgroups* limit the amount of system resources (CPU, memory, bandwidth...) a process can use.
- *Cgroups* are a linux kernel feature

### 1.2.2 Introducing the Docker Container Platform

- Docker is a containerization technology.
- Docker makes packaging apps, their libraries, their dependencies, and even their OS file system in a simple, cross-platform way.
- A docker container runs the same no matter what hardware, or OS it's running on.
- Of course, docker containers don't include the kernel when they're packaged, do this will vary between systems.
- Docker containers are transported as container images, which are smaller than VM images because they don't include the entire OS.
- Docker container images are composed of layers. This makes downloading images whose base layers you already have much faster.

#### Understanding Docker Concepts

- 3 main docker concepts:
  1. __Images__: A packaged version of your application.
    - Includes the filesystem and other metadata such as executable paths.
  2. __Registries__: A repo for storeing and sharing images.
  3. __Containers__: Docker containers are just linux containers created from docker images. Linux containers, as we've discussed, are processes that are isolated by namespace and resource-constrained with cgroups.

#### Buiding, Distributing and Running a Docker Image

- Sharing images through a repo makes using and extending existing images simple and easy.

#### Comparing Virtual Machines and Docker Containers

- Docker containers share dependencies and libraries.
- Docker containers' portability is limited by their kernel.

##### Understanding Image Layers

- Docker containers share dependencies and libraries by using other images at a lower layer.

- Advantages of sharing dependencies:
  - Distribution of images is easier
  - Images take up less space on disk

- Containers make separate copies of files in shared lower layers when they make changes to them, otherwise they would interfere with other containers. 
  - Containers' lower layer files are read-only. When a container is run, a new writable layer is created on top of the layers in the image. When one of the files is edited, the file is copied and the process writes to the copy.

##### Understanding the Porbability limitations

- Because containers don't run their own kernel, they can only run on a host with a compatible kernel.
- Unlike containers, VMs do run their own kernel and can run on any host.
- Kernel compatibility can become a problem when dealing with hardware compatibility (ARM vs x86 for example)

### 1.2.3 Introducing rkt-an Alternative to Docker

- rkt, like docker interfaces with linux containers.
- Docker and rkt are both part of the Open Container Initiative (OCI), who creates open industry standards areound container formats and runtimes.
- rkt emphasises security, composability, and the OCI standards. It can even run docker images.
- Kubernetes supports both Docker and rkt, but this book only uses Docker.

## 1.3 Introducing Kubernetes

- Kubernetes was released in 2014, after a decade of google working in secret with similar internal tools called Borg and later Omega.

### 1.3.2 Looking at Kubernetes from the Top of a Mountain

- Kubernetes allows easy deployment and management of containerized applications.

- Remember:
  - Containers can be heterogenous. Deploying apps through Kubernetes is always the same.
  - Containers can be automatically deployed.
  - Containers are isolated
  - Containers abstract hardware into a single resource.

#### Understanding the Core of What Kubernetes Does

- Kubernetes has 1 master node and worker nodes.
- The master node deploys apps to worker nodes.

- Developers and Ops don't and shouldn't care what node an app is deployed to.
  - Although developers can specify that certain apps run on a node together.
  - Apps communicate the same way, no matter what node they're on.

#### Helping Developers Focus on the Core App Features

- Kubernetes is like an OS for a cluster. It automatically handles tasks like:
  - service discovery
  - scaling
  - load-balancing
  - self-healing
  - leader election

- Before kubernetes, developers had to manage these tasks themselves.

#### Helping Ops Teams Achieve Better Resource Utilization

- Kubernetes dynamically locates the app in the cluster. This enables efficient resource utilization.

### 1.3.3 Understanding the Architecture of a Kubernetes Cluster

- Kubernetes has 2 types of nodes
  1. __A Master node__: which hosts the *kubernetes control plane* that control and manages the whole kubernetes system. 
  2. __Worker nodes__: That run the applications you deploy

- Ch 11 explains these components in more detail.

#### The Control Plane

- The __control plane__ is a set of the following components (possibly spread across nodes) that control the cluster.
  - The __Kubernetes API Server__, which you and other Control Plane components communicate with
  - The __Scheduler__ which schedules apps
  - The __Controller Manager__ which performs cluster-level functions, like replicating components, keeping track of worker nodes, handling node failures...
  - __etcd__, a distributed data store for cluster configuration.

#### The Nodes

- Worker nodes run, monitor, and provide services to applications. They consist of the following components:
  - A __container runtime__ like Docker, rkt that runs your containers.
  - A __Kubelet__ which talks to the API server and manages the container runtime.
  - The __Kubernetes Service Proxy (kube-proxy)__ which load-balances network traffic between application components.

### 1.3.4 Running an Application in Kubernetes

- 