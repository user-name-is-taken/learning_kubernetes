#! /bin/bash -f

#getting the username and password
microk8s.kubectl config view | grep username:
microk8s.kubectl config view | grep password:

#getting the token
token=$(microk8s.kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
microk8s.kubectl -n kube-system describe secret $token | grep token:
