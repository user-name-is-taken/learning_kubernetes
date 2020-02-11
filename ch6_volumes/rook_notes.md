# rook notes


# install points

- [main page](https://rook.io/docs/rook/v1.2/k8s-pre-reqs.html)

- Do we have `rbd` installed
  - `modprobe rbd` (no response = it works?)
  - https://rook.io/docs/rook/v1.2/k8s-pre-reqs.html
  - rbd --help gives an install recommendation.

- Have we setup the permissions?
  - https://rook.io/docs/rook/v1.2/psp.html

- kernel version is `4.15.0-74-generic GNU/Linux`
  - Too low for [ceph](https://rook.io/docs/rook/v1.2/k8s-pre-reqs.
  html)?

## other points

- (rbd isn't ReadWriteMany)[https://stackoverflow.com/questions/46097435/kubernetes-ceph-storageclass-with-dynamic-provisioning]
- 

## setting default storage class

- [docs](https://kubernetes.io/docs/tasks/administer-cluster/change-default-storage-class/)
- related github issue
- [dynamic provisioning](https://kubernetes.io/blog/2017/03/dynamic-provisioning-and-storage-classes-kubernetes)
- [dynamic provisioning ceph](https://docs.okd.io/latest/install_config/persistent_storage/dynamically_provisioning_pvs.html)

## kustomize

- seems cool... (easier than helm)

## rook/ceph stuff

### Random links

- [ceph notes](https://ceph.io/install/)
- 