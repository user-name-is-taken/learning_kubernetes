# ch5 Services Overview

- This chapter covers:
  - Creating Service resources to expose a group of pods at a single address
  - Discovering services in the cluster
  - Exposing Services to external clients
  - Conntecting to external services from inside the cluster
  - Controlling whether a pod is ready to be part of the service or not
  - Troubleshooting servics

- Services allow a group of pods to be accessible over a single IP address.

- You can't point to a single pod's IP because:
  - *Pods are ephemeral*
  - *Kubernetes assignes an IP address to a pod after the pod has been schdeuled to a node and before it's started* so client's can't know the pod's IP before it's started
  - *Horizontal scaling means multiple pods may provide the same service* Clients shouldn't have to load balance across the pods themselves.

## 5.1 Introducing Services

- A service's external IP address and port never change while the service exists.
- Services route incoming traffic to the various pods backing the service

#### Explaining Services with an Example

- A typical website has a front-end that connects to a back-end database. In this architecture, users connect to the front-end through a service, then the front-end connects to the database through a service.

### 5.1.1 Creating Services

- Services, like ReplicaSets use label-selectors to specify which pods they are backed by.
- We'll now re-create a test replication-controller from last chapter ([kubia-rc.yaml](../ch4_replication_controllers_etc/exercises/kubia-rc.yaml)), then we'll create a service for it.

```sh
$ kubectl create -f ../ch4_replication_controllers_etc/exercises/kubia-rc.yaml
replicationcontroller/kubia created

$ kubectl get rc
NAME    DESIRED   CURRENT   READY   AGE
kubia   3         3         3       12s
```

### Creating a Service Through kubectl Expose

- The easiest way to create a service is using `kubectl expose` which creates a service with the same pod selector as the replication controller.
- 