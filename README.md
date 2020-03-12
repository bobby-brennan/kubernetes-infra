# Personal Kubernetes Clusters
I use this repository to host my own Kubernetes infrastructure.
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
* Self-healing infrastructure reduces operational toil

#### How to use this repository
I've used two methods for hosting a cluster:
* **KIND running on a single machine**. This is good for prototyping, but it was painful long-term. 
* **A managed cluster on DigitalOcean**. This has been a much better experience. Unfortunately restoring data from backups is currently difficult/incomplete.

Setup takes a few steps:
* For a DigitalOcean or other managed cluster
  * Provision the cluster
  * Install the utilities
  * Point your domain to the managed load balancer
* For single-machine clusters w/ KIND:
  * Provision a new machine (e.g. an EC2 instance)
  * Point your domain to the machine
  * Start the KIND cluster
* Set up automated backups
* Install apps!

#### Requirements
For a single machine on EC2, a `t2.medium` is recommended, but it seems to work on a `t2.small` as well, which run for ~$30/month and ~$15/month respectively. This has been tested using Ubuntu 18.04, but other operating systems should work

On DigitalOcean, a cluster with two $10/mo nodes seems to work well.

#### Dependencies
If you plan on using a single-machine cluster, you'll need KIND (Kubernetes in Docker) to run the cluster. You'll need to have
[Docker installed](https://phoenixnap.com/kb/how-to-install-docker-on-ubuntu-18-04)
```
curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.6.0/kind-$(uname)-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/
```

We also use [Helm](https://github.com/helm/helm) and [Reckoner](https://github.com/FairwindsOps/reckoner) to manage applications
```
curl -L "https://get.helm.sh/helm-v3.0.2-linux-amd64.tar.gz" > helm3.tar.gz
tar -xvf helm.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/
rm -rf linux-amd64

pip3 install reckoner
```

## Create the Cluster

### DigitalOcean
* Create cluster using DO UI
* Download KUBECONFIG from DO UI and place it in .kubeconfig
* run `./scripts/setup-cluster.sh`
* run `helm upgrade --install cert-issuer ./charts/cert-issuer --set email=you@example.com`
* find the new load balancer created in the DO UI
* set that IP address in your DNS configuration


### KIND
> If you want to start again from scratch, you can run `kind delete cluster`
> and run these instructions again

To get up and running with a cluster, run:
```
./scripts/create-kind.sh
helm upgrade --install cert-issuer ./charts/cert-issuer --set email=you@example.com
````

## Backups
### Automated Cloud Volume Backups
[k8s-snapshots](https://github.com/miracle2k/k8s-snapshots) can be used with
certain cloud providers to create automated backups.

```
helm upgrade --install k8s-snapshots -n k8s-snapshots ./charts/k8s-snapshots/ \
  --set digitalOceanAccessToken=$DIGITALOCEAN_ACCESS_TOKEN
```

The script `./scripts/retain.sh` will annotate your PVCs with a schedule to keep 14 days worth
of daily backups.

#### Restoring
> This will definitely cause downtime. PRs accepted

To restore a volume on Digital Ocean:
* take a snapshot of the existing volume
* delete the existing volume
* create a volume from the snapshot you want to use
  * use the PVC ID for the name (should be the same name as the volume you deleted)
  * attach it to the same node
* power cycle the node

### KIND Backups
> TODO: add terraform for managing the S3 Bucket

We use AWS CLI v2 to manage backups:
```
curl "https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

You're going to be storing your application data in `~/kind-disk`. It's easy for this data
to get suddenly deleted, as it's being managed by the cluster. You should _definitely_ back this
up somewhere.

This repo comes with two scripts: `./scripts/backup.sh` and `./scripts/restore.sh`. These
will store your backups in an Amazon S3 bucket.

#### Set up the bucket
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

#### Backup on a schedule
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
which will set all PVs to `RETAIN` mode. It will also add `k8s-snapshots` annotations if you're using cloud backups.

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

