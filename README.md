# Personal Kubernetes Clusters
I use this repository to self-host a single-machine Kubernetes cluster.
It includes out-of-the-box configuration for a few apps:
* a Markdown editor (HackMD)
* a blogging platform (Ghost)
* a Photo sharing application (Lychee)
* a chatroom (RocketChat)

#### How to use it
Setup takes a few steps:
* Provision a new machine (e.g. an EC2 instance)
* Point your domain to the machine
* Start the KIND cluster
* Set up automated backups
* Install apps!

#### Requirements
On EC2, a `t2.medium` is recommended, but it seems to work on a `t2.small` as well, which run for ~$30/month and ~$15/month respectively.

This has been tested using Ubuntu 18.04, but other operating systems should work

#### Dependencies
We use KIND (Kubernetes in Docker) to run the cluster. You'll need to have
[Docker installed](https://phoenixnap.com/kb/how-to-install-docker-on-ubuntu-18-04)
```
curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.6.0/kind-$(uname)-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/
```

We also use [Helm](https://github.com/helm/helm) and [Reckoner](https://github.com/FairwindsOps/reckoner) to manage applications
```
curl -L "https://get.helm.sh/helm-v2.16.1-linux-amd64.tar.gz" > helm.tar.gz
tar -xvf helm.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/
sudo mv linux-amd64/tiller /usr/local/bin/
rm -rf linux-amd64

pip install reckoner
```

## Create the Cluster
> If you want to start again from scratch, you can run `kind delete cluster`
> and run these instructions again

To get up and running with a cluster, run:
```
./start.sh
helm upgrade --install cert-issuer ./charts/cert-issuer --set email=you@example.com
````

## Setup Backups
You're going to be storing your application data in `~/kind-disk`. It's easy for this data
to get suddenly deleted (it's being managed by the cluster). You should _definitely_ back this
up somewhere.

This repo comes with two scripts: `./scripts/backup.sh` and `./scripts/restore.sh`. These
will store your backups in an Amazon S3 bucket.

### Set up the bucket
Head over to AWS and create a new S3 bucket. You'll also want to create an IAM profile
to use for interacting with the bucket. See [iam-profile-for-backups.json](iam-profile-for-backups.json)
for a good minimal profile, but be sure to replace `$S3_BACKUP_BUCKET` with your bucket name.

You'll probably also want to delete backups older than N days, so your storage costs don't just
increase indefinitely. In your bucket settings, head to `Management -> Lifecycle -> Add lifecycle rule`
and choose `Expire current version of object`, setting the desired number of days.

To create a backup, run:
```
S3_BACKUP_BUCKET=your-bucket-name ./scripts/backup.sh
```

To restore a backup for a particular app, you'll need both the volume name and the backup time, e.g.:
```
S3_BACKUP_BUCKET=your-bucket-name ./scripts/restore.sh hackmd.hackmd-postgresql 1574286441
```

You'll probably need to restart your app as well:
```
# Scale down
kubectl scale deployment hackmd-postgresql --replicas=0
kubectl scale deployment hackmd --replicas=0

# Scale back up
kubectl scale deployment hackmd-postgresql --replicas=1
kubectl scale deployment hackmd --replicas=1
```

## Install Apps

Follow the instructions below to install one of the applications.

### HackMD
```
export HACKMD_POSTGRESS_PASSWORD=foobar
export HACKMD_HOST=hackmd.yourdomain.com
reckoner plot apps/hackmd/course.yaml
```

If you want to make sure your data doesn't get deleted if you uninstall HackMD,
be sure to run:
```
./scripts/retain.sh
```

### Lychee
```
k apply -f ./apps/lychee/
```

### rocketchat
```
reckoner plot apps/rocketchat/course.yaml --helm-args --set=mongodb.mongodbPassword=$ROCKETCHAT_PASSWORD,mongodb.mongodbRootPassword=$ROCKETCHAT_PASSWORD
```

### Ghost
```
reckoner plot apps/ghost/course.yaml --helm-args --set=ghostPassword=$GHOST_PASSWORD,mariadb.db.password=$GHOST_DATABASE_PASSWORD
```

### polaris
Polaris runs some basic health checks on your applications
```
reckoner plot apps/polaris/course.yaml
```

