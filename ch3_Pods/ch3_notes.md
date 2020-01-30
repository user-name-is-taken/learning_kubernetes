# ch3: pods-Running Containers in Kubernetes

- This chapter covers:
  - Creating, running and stopping pods
  - Organizing pods and other resources with labels
  - Performing an operation on all pods with a specific label
  - Using namespaces to split pods into non-overlapping groups

- Pods is the most important object in kubernetes. Everything else either manages, exposes or is used by pods.

## 3.1 Introducing Pods

- __Pod__: a co-located group of containers.
- Pods are often just a single container.
- Pods never span multiple nodes.

### 3.1.1 Understanding Why We need Pods

#### Understanding Why Multiple Containers are Better than one Container Running Multiple Processes

- Pods provide a logical machine for multiple containers, but keeps these containers seperate to ease log management, manage dependencies, separate files...
  - More on this later

### 3.1.2 Understanding Pods

- Pods allow easy grouping of closely related containers for management.
- Containers in a pod act almost as if they were shared a container. (see the next section)

#### Understanding the Partial Isolation between Containers of the Same Pod

- Containers of a pod share these namespaces:
  - Network (interface)
  - UTS (hostame and domain)
  - Inter-process communication (IPC)
  - In newer versions of kubernetes you can tell pods to share the Process ID (PID) namespace

- Container's of a pod __don't__ share these namespaces:
  - Mount (mnt)
  - User ID (user)
  - PID (depending)

- Sharing the PID namespace means you would see other container's processes when running `ps aux` in your container.
- Note, mount is isolated, but if you mount a volume into a container it's not isolated in the same way. We cover this in ch6.

#### Understanding How Containers Share the Same IP and Port Space

- Because containers in pods share the network namespace:
  - They can't bind to the same ports.
  - They can communicate with other containers in the same pod on localhost

#### Introducing the Flat Inter-Pod Network

- The flat inter-Pod network means that pods see each other as though they were on the same LAN.
  - There's no NAT between the pods. The IP address the pod uses is the same IP any other pod in the network sees it on.
  - This is true even if your nodes are on different networks. This is achieved with a software-defined network translating IP addresses.

### 3.1.3 Organizing Containers Across Pods Properly

- Running multiple containers in a single pod doesn't save any resources. The only reason to do it is to share the above mentioned namespaces.

#### Splitting Multi-Tier Apps into Multiple Pods

- Putting containers in their own pods allows Kubernetes to schedule them more effectively.
  - For example, Putting your Database and API in different pods allows kubernetes to put the Database pod on a node with more disk space and your API on a node with a better internet connection.

#### Splitting into Multipl Pods to Enable Individual Scaling

- Splitting containers into multiple pods enables them to be scaled individually.

#### understanding When to Use Multiple Containers in a Pod

- Generally multi-container pods have a main container and supporting containers (called sidecar containers) .
  - Examples: log rotators and collectors, data processors, communication adapters...

- Remember, these components can't be scaled individually!

#### Deciding When to Use Multiple Containers in a Pod

- Ask yourself these questions to determine if you should use a multi-pod container:
  - Do they need to be run together or can they run on different hosts?
  - Do they represent a single whole or or they independend components?
  - Must they be scaled together or individually?

- CH6 will show multi-container pods. For now we focus on single-container pods.

## 3.2 Creating Pods from YAML or JSON Descriptors

- Last chapter, we showed how to run pods with `kubectl run`... now we'll show running containers by posting JSON or YAML scripts to the Kubernetes REST API.

- Benefits of JSON and YAML:
  - They have more options
  - They can be source controlled

### 3.2.1 Examining a YAML Descriptor of an Existing Pod

- `kubectl get pod kubia-d8nw9 -o yaml` shows the yaml definition of the `kubia-d8nw9` pod

- Important parts of the YAML description include:
  - The Kubernetes API version: `apiVersion`
  - The type of Kubernetes object/resource: `kind`
  - Pod metadata (name, labels, annotations...): `metadata`
  - Pod specification/contents (list of pod's containers, volumes...): `spec`
  - Detailed status of the pod and its containers: `status`

#### Introducing the Main Parts of a Pod Definition

- The important sections
  - `metadata` includes the name, namespace, labels, etc about the pod.
  - `spec` describes the pod's contents (volumes, etc.)
  - `status` has curent information (condition, container status, internal IP) about the running pod
      - This is read-only and run-time data.
      - You don't need to provide this when creating a pod.

- Other kubernetes objects also have YAML/JSON descriptions (with a different `kind` field).

### 3.2.2 Creating a Simple YAML Descriptor for a Pod

- In this section, we create [kubia-manual.yaml](./exercises/kubia-manual.yaml) to demonstrate creating a pod with YAML.
- The pod's name is kubia based on the michaellundquist/kubia image, and it's exposing port 8080.

#### Specifying Container Ports

- Specifying ports in the YAML is purely informational. If they're omitted, the containers inside the pod can still speak on the ports they're mapping.
- Explicitly assigning ports also allows you to name the port. This will be useful later.

#### Using `kubectl explain` to discover possible API object fields

- To see what attributes are available in kubernetes you can:
  - go to [kubernete's website](https://kubernetes.io)
  - use the explain command

- For example, `kubectl explain pods` will show you information about the 5 major fields (apiVersion, kind, metadata, spec, status)
- To get more information about a field, use dot notation. For example `kubectl explain pods.spec` will give you informatino about the spec field.

### 3.2.3 Using `kubectl create` to create the pod.

```sh
$ kubectl create -f ./exercises/kubia-manual.yaml
pod/kubia-manual created
```
- You use this same command to create other resources too (not just pods)

#### Retrieving the Whole Definition of a Running Pod

- As we've seen, to get the definition of kubia-manual use `$ kubectl get po kubia-manual -o yaml`
- you can use `-o json` instead of `-o yaml` to get json output instead.

#### Seeing Newly Created pod in the List of Pods

```sh
kubectl get pods
NAME           READY   STATUS    RESTARTS   AGE
kubia-f8r2b    1/1     Running   0          43m
kubia-manual   1/1     Running   0          8m45s
```

### 3.2.4 Viewing Application Logs

- Linux process'es logs are output to standard out/standard error.
- Docker redirects those output streames to files and allows you to get the container's log by running `$docker logs <container id>`
- You could ssh into a node where your pod is running and retrieve its logs wit hdocker logs, but Kubernetes provides an easier way.

#### Retrieving a Pod's Log with kubectl Logs

- To see a pod's logs:

```sh
$ kubectl logs kubia-manual
Kubia server starting...
```

- Getting pod logs is simple with a single container.
- Container logs are rotated daily and every time the log file reaches 10MB

#### Specifying the Container Name when Getting Logs of a Multi-Container Pod

- `kubectl log`'s `-c <container name>` flag allows you to get the logs for a specific container.
- kubia-manual only has the kubia container, so the logs don't change, but you could see its logs like this

```sh
$ kubectl logs kubia-manual -c kubia
Kubia server starting...
```

- use `-f` to follow logs
- When a pod gets deleted, it's logs get deleted. You can keep the pods logs by configuring centralized, cluster-wide logging (see ch17)

### 3.2.5 Sending Requests to the Pod

- Here we look at port forwarding to a pod.

#### Forwarding a Local Network Port to a Port in the Pod

- Portforwarding is for __debugging__, not production.
- Note, on a minikube local instance, you need to install socat for this to work `$ sudo apt-get install socat`
- To forward localhost's port 8888 to kubia-manual's 8080:

```sh
$ kubectl port-forward kubia-manual 8888:8080
Forwarding from 127.0.0.1:8888 -> 8080
Forwarding from [::1]:8888 -> 8080
```

#### Connecting to the Pod Through the Port Forwarder

- With the port forwarded, you can curl directly to the pod.

```sh
$ curl localhost:8888
You've hit kubia-manual
```

## 3.3 Organizing Pods with Labels

- Often, applications have so many pods that they need a way of categorizing them.
  - This is especaially true with multiple releases (stable, beta, canary...) and multiple replicas

- Labels provide a way to apply commands to a subset of pods and can limit views by these labels.

### 3.3.1 Introducing Labels

- Any kubernetes resource can be labeled
- Labels are key-value pairs you attach to a resource, which is then utilized when selecting resources using *label selectors* (resources are filtered based on whether they include the label specified in the selector).
  - __canary release__ is when you deploy a new version of an application next to the stable version, and only let a small fraction of users hit the new version to see how it behaves before rolling it out to all users. This prevents bad releases from being exposed to too many users.

- Resources can have multiple (unique) labels.
- You can add a label to a resource or edit a resource's label at any point without having to modify the resource.

### 3.3.2 Specifying Labels When Creating a Pod

- [kubia-manual-with-labels.yaml](./exercises/kubia-manual-with-labels.yaml) includes 2 labels for the pod (`creation_method=manual` and `env=prod`) in the metadata.labels section.

```sh
$ kubectl create -f ./exercises/kubia-manual-with-labels.yaml 
pod/kubia-manual-v2 created
```

- To include the labels when you get pods:

```sh
$ kubectl get po --show-labels 
NAME              READY   STATUS    RESTARTS   AGE    LABELS
kubia-f8r2b       1/1     Running   0          135m   run=kubia
kubia-manual      1/1     Running   0          28m    <none>
kubia-manual-v2   1/1     Running   0          92s    creation_method=manual,env=prod
```

- To only include certain labels:

```sh
 kubectl get po -L creatino_method,env
NAME              READY   STATUS    RESTARTS   AGE     CREATINO_METHOD   ENV
kubia-f8r2b       1/1     Running   0          136m                      
kubia-manual      1/1     Running   0          29m                       
kubia-manual-v2   1/1     Running   0          2m28s                     prod
```

### 3.3.3 Modifying Labels of Existing Pods

- kubia-manual was also created manually, so here we'll add the creation_method=manual and env=debug labels to it:

```sh
$ kubectl label po kubia-manual env=debug creation_method=manual
pod/kubia-manual labeled
$ kubectl get po -L creation_method,env
NAME              READY   STATUS    RESTARTS   AGE     CREATION_METHOD   ENV
kubia-f8r2b       1/1     Running   0          141m                      
kubia-manual      1/1     Running   0          34m     manual            debug
kubia-manual-v2   1/1     Running   0          7m18s   manual            prod
```

- To change these labels, do the same command with the `--overwrite` flag.

## 3.4 listing Subsets of Pods Through Label Selectors

- __label selectors__ allow you to select a subset of resources tagged with certain labels and perform an operation on those resources.

- Label selectors can filter based on wheather the resource:
  - Contains (or doesn't contain) a label with a certain key.
  - Contains a label with a certain key and value
  - Contains a label with a certain key, but with a value not equal to the one you specify

### 3.4.1 Listing Pods Using a Label Selector

- To just see pods with the `creation_method=manual` label:

```sh
$ kubectl get po -l creation_method=manual -L creation_method
NAME              READY   STATUS    RESTARTS   AGE   CREATION_METHOD
kubia-manual      1/1     Running   0          54m   manual
kubia-manual-v2   1/1     Running   0          27m   manual
```

- To list pods with the `env` label:

```sh
$ kubectl get po -L env -l env
NAME              READY   STATUS    RESTARTS   AGE   ENV
kubia-manual      1/1     Running   0          53m   debug
kubia-manual-v2   1/1     Running   0          26m   prod
```

- To get pods that don't have the env label

```sh
$ kubectl get po -l '!env' -L env
NAME          READY   STATUS    RESTARTS   AGE    ENV
kubia-f8r2b   1/1     Running   0          163m   
```

- Make sure you use single quotes so bash doesn't evaluate the !

- Other selectors:
  - `creation_method!=manual` to select pods with the `creation_method` label with any value other than manual
  - `env in (prod,devel)` to select pods with the `env` label set to either `prod or devel`
  - `env notin (prod,devel)` to select pods with the `env` label set to any value other than `prod or devel`

### 3.4.2 Using Multiple Conditions in a Label Selector

- To use multiple selectors use a comma separated list.

```sh
 kubectl get po -L env,creation_method -l env=prod,creation_method
NAME              READY   STATUS    RESTARTS   AGE   ENV    CREATION_METHOD
kubia-manual-v2   1/1     Running   0          34m   prod   manual
```

- Label selectors aren't useful only for selecting pods, but also for performing actions on a subset of pods.
- Label selectors aren't just used by kubectl but are also used internally.

## 3.5 Using Labels and Selectors to Constrain Pod Scheduling

- You shouldn't tell kubernetes what node to run your pod on because that couples the application to the infrastructure, but some applications need certain resources that only certain nodes have.
- You can use labels and node label selectors to tell kubernetes that a pod needs resources that only certain nodes have.

### 3.5.1 Using Labels for Categorizing Worker Nodes

- To label that the minikube node has a GPU:

```sh
$ kubectl label node minikube gpu=true
node/minikube labeled
$ kubectl get nodes -L gpu
NAME       STATUS   ROLES    AGE   VERSION   GPU
minikube   Ready    master   28h   v1.17.0   true
```

### 3.5.2 Scheduling Pods to Specific Nodes

- To tell the scheduler to onnly choose from nodes with a certain label, we use the `pod.spec.nodeSelector` attribute.
- See [kubia-gpu.yaml](./exercises/kubia-gpu.yaml) for an example

```sh
$ kubectl create -f ./exercises/kubia-gpu.yaml 
pod/kubia-gpu created
```

### 3.5.3 Scheduling to one Specific Node

- Every node has the label `kubernetes.io/hostname` whose value is its hostname.

```sh
$ kubectl get node -L kubernetes.io/hostname
NAME       STATUS   ROLES    AGE   VERSION   HOSTNAME
minikube   Ready    master   29h   v1.17.0   minikube
```

- If you wanted your pod to run on a single node, you could set `pod.spec.nodeSelector` to `kubernetes.io/hostname: "<hostname>"` but this IS BAD!
- Labels and label selectors are useful in the next 2 chapters about Replication-Controllers and Services.
- Additional way of influencing which node a pod is scheduled to are covered in ch16.

## 3.6 Annotating Pods

- __Annotations__ are key-value pairs used to hold large pieces of information meant to be used by tools.
- Unlike labels, annotations can't be used to group objects. There's no equivalent to label selectors for annotations.
- Certain annotations are added by kubernetes automatically, but you can add your own annotations.
- Kubernetes developers often use annotations to introduce new features to kubernetes. Once the new features are agreed upon, fields are added and their related annotations are deprecated.
- Kubernetes users often add annotations to objects to describe the objects. For example, a developer might add their name to the object so other developer's know who created it.

### 3.6.1 Looking up an Object's Annotations

- Annotations are stored in an object's description at `<object>.metadata.annotation`
- Remember you can view an object's description with the `-o yaml` flag of `kubectl get`

### 3.6.2 Adding and Modifying Annotations

- You can add annotations to an object at creation in it's yaml (as with labels)
- You can add an annotation to an existing object like this:

```sh
$ kubectl annotate pod kubia-manual mycompany.com/someannotatino="foo bar"
pod/kubia-manual annotated
$ kubectl describe pod kubia-manual | grep annot
Annotations:  mycompany.com/someannotatino: foo bar
```

- Annotating with the <websitename>/<key> helps avoid key collisions.

## 3.7 Using Namespaces to Group Resources

- __Namespaces__ can split objects into non-overlapping groups.
  - Note, this is different than kubernetes namespace

- Namespaces are different from labels because:
  - A resource can only be in 1 namespace
  - A resource can have no labels

- Namespaces allow you to:
  - Perform functions on only resources inside the namespace.
  - Re-use a resource name on resources in different namespaces.

### 3.7.1 Understanding the Need for Namespaces

- Some types of resources aren't namespaced. For example, nodes aren't namespaced.

### 3.7.2 Discovering other Namespaces and Their Pods

- To see all your namespaces:

```sh
$ kubectl get ns
NAME                   STATUS   AGE
default                Active   2d1h
kube-node-lease        Active   2d1h
kube-public            Active   2d1h
kube-system            Active   2d1h
kubernetes-dashboard   Active   26h
```

- By default, kubernetes performs all commands in the `default` namespace.
- To see what's in other namespaces use the `--namespace <namespace>` command:

```sh
$ kubectl get --namespace kube-system pods
NAME                               READY   STATUS    RESTARTS   AGE
coredns-6955765f44-l4jvr           1/1     Running   1          2d1h
coredns-6955765f44-ntsfm           1/1     Running   1          2d1h
etcd-minikube                      1/1     Running   1          2d1h
kube-addon-manager-minikube        1/1     Running   1          2d1h
kube-apiserver-minikube            1/1     Running   1          2d1h
kube-controller-manager-minikube   1/1     Running   1          2d1h
kube-proxy-825q8                   1/1     Running   1          2d1h
kube-scheduler-minikube            1/1     Running   1          2d1h
storage-provisioner                1/1     Running   2          2d1h
```

- The `kube-system` namespace is a good usecase for namesapces. It's used to keep system resources separate from other resources so you don't accidentally delete them.
- Namespaces are a good way to give user's their own set of distinct resources.
- We'll see in chapters 12 and 14 we'll see how to authenticate access to namespaces and how to limit the computational resources available in a namespace.

### 3.7.3 Creating a Namespace

- namespaces are themselves kubernetes resources.
- You can create namespaces by posting a YAML file to the API.

#### Creating a Namespace from a YAML File

- To create a new namespace [custom-namespace.yaml](./exercises/custom-namespace.yaml):

```sh
$ kubectl create -f ./exercises/custom-namespace.yaml 
namespace/custom-nsamespace created
```

#### Creating a Namespace with `kubectl create namespace`

- Creating a namespace is slow, so here's a dedicated command for it:

```
$ kubectl create namespace custom-namespace
namespace/custom-namespace created
```

- Namespaces aren't allowed to contain dots!

### 3.7.4 Managing Objects in other Namespaces

- To make resources in your new namespace either:
  - add a `namespace: custom-namespace` to your metadata section
  - specify the namespace when creating the resource with the `kubectl create` command 

`$ kubectl create -f ./exercises/kubia-manual.yaml -n custom-namespace`

- Now we have two pods named `kubia-manual` in two different namespaces.
- To interact with kubia-manual in custom-namespace, you need to include the namespace flag
- You can change the current namespace like this:

```sh
$ kubectl config set-context $(kubectl config current-context) --namespace custom-namespace
Context "minikube" modified.
$ kubectl get pods
NAME           READY   STATUS    RESTARTS   AGE
kubia-manual   1/1     Running   0          4m4s
```

### 3.7.5 Understanding the Isolation Provided by Namespaces

- Although namespaces isolate resources, they don't isolate them in the same ways linux namespaces do.
- For example, pods can ping across namespaces.

## 3.8 Stopping and Removing Pods

- We don't need all the pods we've created, so now we stop them.

### 3.8.1 Deleting a Pod by Name

- First, switch back to the default namespace

`$ kubectl config set-context $(kubectl config current-context) --namespace default`

- Then Delete the `kubia-gpu` pod by name

```sh
$ kubectl delete pod kubia-gpu 
pod "kubia-gpu" deleted
```

- To delete a pod kubernetes:
  - Sends the pod a __SIGTERM__
  - Waits 30 seconds for the pod to shut down
  - If the pod didn't die it sends a __SIGKILL__

- The delete command takes multiple arguments i.e. `kubectl delete po pod1 pod2`

### 3.8.2 Deleting Pods Using Label Selectors

- To delete pods using a label selector:

```sh
$ kubectl delete po -l creation_method=manual
pod "kubia-manual" deleted
pod "kubia-manual-v2" deleted
```

### 3.8.3 Deleting Pods by Deleting the Whole Namespace

- If you delete a namespace, its pods are deleted too:

```sh
$ kubectl delete ns custom-namespace 
namespace "custom-namespace" deleted
```

### 3.8.4 Deleting All Pods in a Namespace, While Keeping the Namespace

- Now we have just 1 pod left:

```sh
 kubectl get pods
NAME          READY   STATUS    RESTARTS   AGE
kubia-f8r2b   1/1     Running   0          24h
```

- To finish up, we'll delete all pods in the namespace:

```sh
$ kubectl delete po --all
pod "kubia-f8r2b" deleted
```

- `kubia-f8r2b` was deleted, but the replication-controller created a new pod to replace it:

```sh
$ kubectl get pods
NAME          READY   STATUS    RESTARTS   AGE
kubia-jzxfg   1/1     Running   0          69s
```

### 3.8.5 Deleting (Almost) All Resources in a Namespace

- To delete the ReplicationControoler, the Pods and the Services we made:

```sh
$ kubectl delete all --all
pod "kubia-jzxfg" deleted
replicationcontroller "kubia" deleted
service "kubernetes" deleted
service "kubia" deleted
service "kubia-http" deleted
```

- The first `all` specifies we're deleting all resource types. The second specifies we're deleting everything matching that criteria.
- Note, this doesn't delete everything. Certain resources, like secrets (ch 7) are preserved.
- This command also deleted the kubernetes service, but that gets re-created.

## 3.9 Summary

- This chapter covered:
  - Pods are Co-located containers
  - When to include multiple containers in a pod
  - Pods are similar to a physical host in the real world
  - using YAML and JSON to create pods
  - Using labels and Label selectors to organize pods, schedule pods, and perform operations on multiple pods.
  - Annotations
  - Namespaces
  - `kubectl explain`