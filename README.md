# Personal Kubernetes Clusters
I use this repository to self-host a single-machine Kubernetes cluster.
It includes out-of-the-box configuration for a few apps:
* a Markdown editor (HackMD)
* a blogging platform (Ghost)
* a Photo sharing application (Lychee)
* a chatroom (RocketChat)

#### Why?
Kubernetes is typically thought of as a way to deploy highly scalable, resilient
applications. For hosting personal projects, a blog, etc, it could be argued that
Kubernetes is overkill, especially given how complex Kubernetes is.

But Kubernetes is good for more than just scalability and resilience. The ecosystem that
has grown up around Kubernetes has made it an ideal way to create and manage deployments,
both of your own projects, and of third-party software. Kubernetes is quickly becoming
the de facto computing platform, supported by all major cloud vendors. And nearly every
open source project comes with a Dockerfile, if not a Helm chart, making installation a
breeze.

Here are a few benefits that come with using Kubernetes for a personal cluster:
* Any dockerized application can be easily installed
* CPU and memory resources can be tightly controlled
* High degree of separation between different applications
* Infrastructure-as-code makes deployments highly reproducible and easy to reason about
* Self-healing infrastructure helps reduce operational costs

#### How to use this repository
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

Finally, we'll use the AWS CLI v2 to manage backups:
```
curl "https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
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
> TODO: add terraform for managing the S3 Bucket

You're going to be storing your application data in `~/kind-disk`. It's easy for this data
to get suddenly deleted, as it's being managed by the cluster. You should _definitely_ back this
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

### Backup on a schedule
Use your crontab to automatically back up every day
```
crontab -l | { cat; echo "0 0 * * * S3_BACKUP_BUCKET=your-bucket-name /path/to/this/dir/scripts/backup.sh"; } | crontab -
```

### Persist your data
When an app is uninstalled, it will delete the corresponding data by default.
To change this, every time you install an app, you should run
```
./scripts/retain.sh
```
which will set all PVs to `RETAIN` mode.

This is done automatically for HackMD and Ghost.

## Install Apps

Follow the instructions below to install one of the applications.

### HackMD
```
export HACKMD_POSTGRESS_PASSWORD=foobar
export HACKMD_HOST=hackmd.yourdomain.com
reckoner plot apps/hackmd/course.yaml
```

### Ghost
```
export GHOST_USERNAME=foo@bar.com
export GHOST_PASSWORD=foo
export GHOST_HOST=blog.yourdomain.com
reckoner plot apps/ghost/course.yaml
```

### Lychee
```
k apply -f ./apps/lychee/
```

### rocketchat
```
reckoner plot apps/rocketchat/course.yaml --helm-args --set=mongodb.mongodbPassword=$ROCKETCHAT_PASSWORD,mongodb.mongodbRootPassword=$ROCKETCHAT_PASSWORD
```

### polaris
Polaris runs some basic health checks on your applications
```
reckoner plot apps/polaris/course.yaml
```

