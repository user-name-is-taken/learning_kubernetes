# ckad practice notes

- Look into GNU screen for terminal multiplexing
- you can get the hostname of your nodes with `kubectl get nodes` then ssh into that node
- You can use ​ kubectl ​ and the appropriate context to work on any cluster from the base node.
When connected to a cluster member via ​ ssh​ , you will only be able to work on that particular
cluster via ​ kubectl.
- Backup resources before destroying them so you can re-create them after!!!!
- k8s 1.17 currently, will be k8s 1.18
- 