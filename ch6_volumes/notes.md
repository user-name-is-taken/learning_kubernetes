# Volumes

- This chapter covers:
  - Creating multi-container pods
  - Creating a volume to share disk storage between containers
  - Using a Git repository inside a pod
  - Attaching persistent storage such as a GCE Persistent Disk to pods
  - Using pre-provisioned persistent storage
  - Dynamic provisioning of persistent storage

- This chapter covers how pods access storage and share storgage between pods.
- Containers' storage is isolated (and not persistant) because the filesystem namespace is isolated.
- Here, we learn how use *volumes* to persist storage across containers (but not pods). Note, volumes live inside pods. Their lifecycle is the same as the pod's.

## 6.1 Introducing Volumes

- Volumes are components of pods, and are therefore defined in the pod's specification- like containers.
- Volumes aren't standalone kubernetes objects and can't be created or deleted on their own.
- Containers *mount* volumes into the filesystem to use them.

### 6.1.1 Explaining Volumes in an Example

- An example use-case of volumes is a pod, running a web-server container sharing data with a log manager container and a content agent.
- Volume are bound to the lifecycle of a pod, but depending on the volume tyep, the volume files may remain intact even after the pod and volume disappear, and can later be mounted into a new volume.

### 6.1.2 Introducing Availiable Volume Types

- Volume types
  - __emptyDir__: A simple empty directory used for storing transient data
  - __hostPath__: Used for mounting directories from the worker node's filesystem into the pod
  - __gitRepo__: initialized by checking out the ocntents of a Git repo.
  - __nfs__: an NFS share mounted into the pod
  - __gcePersistentDisk__ (for google Compute)
  - __awsElasticBlockStore__ (for aws)
  - __azureDisk__ (for microsoft)
  - __cinder__, __cephfs__, __iscsi__, __flocker__, __glusterfs__, __quobyte__, __rbd__, __flexVolume__, __vsphere-Volume__, __photonPersistentDisk__, __scaleIO__ - Used for mounting other types of network storage
  - __configMap__, __secret__, __downwartAPI__: special types of volumes used to expose certain kubernetes resources and cluster information to the pod
    - These are covered in teh next 2 chapters because they aren't used for storing data, but for exposing Kubernetes metadata to apps running in the pod.
  - __persistentVolumeClaim__: A way to use a pre- or dynamically provisioned persistent storage.

- A single pod can use multiple volumes of different types at the same time, and each pod's containers can have a volume mounted or not.

## 6.2 Using Volumes to Share Data between Containers

- Volumes are useful for even a single container, but first we look at using them across multiple containers

### 6.2.1 Using an `emptyDir` Volume

- emptyDir volumes start as an empty directory
- emptyDir volumes' lifecycle is tied to the pod.
- emptyDir volumes are useful for sharing data between containers in a pod.
- emptyDir volumes are usefule for single containers when they need to write to disk temporarily. For example working on a large dataset that won't fit in memory.

- Temporary data can also be written directly to the container's file system, but subtle differences exist between this and an emptyDir volume.
  - Sometimes a container's filesystem isn't writable (more on this at the end of the book)

#### using an emptyDir Volume in a Pod

- Here we'll build a pod with a web-server, and a content agent sharing a volume
  - We'll use Nginx as the web server
  - We'll use UNIX fortune to generate a random quote every 10 seconds and store it in index.html
    - The book has instructions on building this yourself, but it's unnecessary.

#### Creating the Pod

- We'll use [fortune-pod.yaml](./examples/fortune-pod.yaml) in this example.

- Notes on syntax:
  - `Pod.spec.containers.volumeMounts` tells which volume to mount with `name`, and where to mount it with `mountPath`. you can also set `readOnly:true` here
  - `Pod.spec.volumes` creates the actual volume.
    - The `emptyDir` property here tells kubernetes this is an emptyDir volume type
  
- We mounted `html` to `/usr/share/nginx/html` in the nginx container because that's where nginx serves content from.

#### Seeing the Pod in Action

- To access the pod, add a port-forwarding rule that points to the pod.

```sh
$ kubectl port-forward fortune 8080:80
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
Handling connection for 8080
Handling connection for 8080

```

- With the port-forwarding running:

```sh
$ curl 127.0.0.1:8080
Beauty and harmony are as necessary to you as the very breath of life.
```

#### Specifying the Medium to Use for the emptyDir

- By default, emptyDir volumes use persistent storage, but you can tell them to be in memory with `Pod.spec.volumes.emptyDir.medium`
- The emptyDir volume type is the simplest type of volume, but other devices like gitRepo volumes build on it.

### 6.2.2 Using a Git Repository as the Starting Point for a Volume

- `gitRepo` volumes are emptyDir volumes with a git repository cloned in them at startup.
  - Note: This won't automatically stay in-sync with the remote

- Now we'll serve a gitRepo volume using nginx

#### Running a Web Server Pod Service Files from a Cloned Git Repository

- I created my own copy of [the example website](https://github.com/luksa/kubia-website-example). If you're following this example, make your own copy now.

- Syntax notes: `Pod.spec.volumes.gitRepo` is where the following repo information is.
  - `repository`
  - `revision`
  - `directory` It's important to specify the directory to `.` so it's cloned into your volume's root directory instead of into a subdirectory of the volume directory for the gitrepo.

```sh
$ kubectl create -f examples/gitrepo-volume-pod.yaml 
pod/gitrepo-volume-pod created

$ kubectl port-forward gitrepo-volume-pod 8080:80
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
Handling connection for 8080
```

- Then from another prompt:

```sh
$ curl 127.0.0.1:8080
<html>
<body>
Hello there.
</body>
</html>
```

#### Confirming the Files aren't Kept in sync with the Git Repo

- Make changes in your github remote and confirm it's not changed locally.
- You could make a process that keeps the git repo in-sync with your pods as an exercise. The following sections cover some information on how you would do this.

#### Introducing Sidecar Containers

- __Sidecar container__: A container that augments the operation of the main container of the pod.
- The git sync process would be run in a sidecar container.
- Sidecar containers keep your main app's code simple and reusable.
- See [git-synced-volume-pod.yaml](./examples/git-synced-volume-pod.yaml) for a pod that runs a sidecar to sync a website.

#### Using a gitRepo Volume with Private Git Repositories

- The gitRepo volume doesn't support cloning over ssh out of the box, but you can add support for it using the sidecar pattern listed above. You will have to modify the image though.

#### Wrapping up the gitRepo Volume

- The gitRepo volume's lifecycle is the same as its pod's.
- Next, we'll cover volumes whose lifecycle isn't tied to their pods.

## 6.3 Accessing Files on the Worker Node's Filesystem

- The `hostPath` volume allows a pod to mount files on the node its running on.
- `hostPath` volumes are useful in DaemonSets (see ch 4)

### 6.3.1 Introducing the hostPath Volume

- Unlike gitRepo and emptyDir volumes, hostPath volumes' lifecycles aren't tied to the pod they're mounted to. Instead, they're tied to the node they're mounted to.
- hostPath volumes are useful for specific, node-related functions. You shouldn't use them for cluster-level things like storing a database.

### 6.3.2 Examining System Pods That Use hostPath Volumes

- System pods (like the kube-proxy) correctly use the hostPath volumes to access a node's `/var/log`, `var/lib/docker/containers`, CA certificates, kubeconfig, and other similar directories.
- For example the kube-proxy has these hostPath volumes:

```sh
$ kubectl describe po -n kube-system kube-proxy-825q8
...
Volumes:
  kube-proxy:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      kube-proxy
    Optional:  false
  xtables-lock:
    Type:          HostPath (bare host directory volume)
    Path:          /run/xtables.lock
    HostPathType:  FileOrCreate
  lib-modules:
    Type:          HostPath (bare host directory volume)
    Path:          /lib/modules
    HostPathType:  
  kube-proxy-token-9kkrz:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  kube-proxy-token-9kkrz
    Optional:    false
...
```

- Importantly, none of the system pods use hostPath volumes for storing their own data, only for accessing the node's data.

## 6.4 Using Persistent Storage

- For storage to persist across pods and nodes, it needs to be independent of any nodes/pods in your cluster on some type of network attached storage (NAS).
- Here we'll run a MongoDB pod and attach a volume to it.

### 6.4.1 Using a GCE Persistent Disk in a Pod Volume

- Here they cover manually provisioning storage on GCE.

#### Creating a GCE Persistent Disk

- create a GCE in the same zone as your cluster
  - Find your cluster's zone with: `$ gcloud container clusters list`
  - Create the disk like this: `$ gcloud compute disks create --size=1GiB --zone=europe-west1-b mongodb`

- `mongodb` is just the name

#### Creating a Pod Using a gcdPersistentDisk Volume

- On minikube