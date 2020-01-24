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

- Microservice's dependencies often conflict (see python 2 vs 3). This makes installing them on the same machine difficult. This can be a problem for dev and ops.

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

- 