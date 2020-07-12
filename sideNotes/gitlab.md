# gitlab

- [docs on linking local k8s to gitlab-ci/cd](https://www.digitalocean.com/community/questions/adding-kubernetes-cluster-to-our-private-gitlab-server)
- Running rasbian in a VM

## gitlab backups

- move pod outside RC using labels:

`kubectl label pods gitlab... name=notGitlab --overwirte`

- make backup in gitlab:
  - https://linuxtechlab.com/simple-guide-backup-restore-gitlab/

- copy out backup

`kubectl cp gitlabContainerName:home/git/data/backups/backupName.tar localfile.tar`

- wait for new gitlab pod to start

- restor to gitlab using ^

## installing new gitlab (with ceph) stack overflow question:

I'm trying to set gitlab to use ceph s3 buckets. [Creating ceph buckets with rook](https://rook.io/docs/rook/v1.2/ceph-object-bucket-claim.html) is easy by creating an object bucket claim that references the bucket storage class which creates an object bucket.

- As far as I can tell I need to create buckets for [these services](https://docs.gitlab.com/charts/advanced/external-object-storage/index.html):
  1. [rails](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/examples/objectstorage/rails.s3.yaml)
  2. [registry](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/examples/objectstorage/registry.s3.yaml)
  3. lfs
  4. artifacts
  5. uploads
  6. packages
  7. externalDiffs
  8. pseudonymizer
  9. backups

- The problem is ceph's s3 secrets don't have the same names as gitlab's [s3 connection secrets](https://docs.gitlab.com/charts/charts/globals.html#connection) expect and gitlab's secrets don't seem to even have a standard even seem to be d.
  -  Ceph secrets' keys are named `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` [as you can see here](https://rook.io/docs/rook/v1.2/ceph-object.html) (note, you can also create a user with keys `AccessKey` and `SecretKey`).

Furthermore, gitlab's secrets aren't named the same across different 

- The current plan is to modify gitlab's helm charts so they can use ceph but this has the following challenges:


## more notes

- gitlab low resource: helm https://github.com/helm/charts/blob/master/stable/gitlab-ce/values.yaml
- gitlab supports helm 3: https://gitlab.com/gitlab-org/charts/gitlab/-/commit/5f3b8d9e2c676ac7371e805ea130b7ccabd789ab