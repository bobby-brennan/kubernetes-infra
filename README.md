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
I use a two-node cluster on DigitalOcean, costing $40/month. It should work just as
well with an EKS or GKE cluster. I've also had some luck using [KIND](https://kind.sigs.k8s.io/),
but I wouldn't recommend it for workloads you care about.

Setup takes a few steps:
* Provision the cluster
* Install the utilities
* Point your domain to the managed load balancer
* Install apps!

## Setup

#### Dependencies

I use [Helm](https://github.com/helm/helm) and [Reckoner](https://github.com/FairwindsOps/reckoner) to manage applications
```
curl -L "https://get.helm.sh/helm-v3.0.2-linux-amd64.tar.gz" > helm3.tar.gz
tar -xvf helm.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/
rm -rf linux-amd64

python3 -m pip install reckoner
```

### Create the Cluster

* Go to digitalocean.com
* Create cluster using DO UI
* Download the KUBECONFIG from DO UI and place it in .kubeconfig
* run `export KUBECONFIG=$PWD/.kubeconfig`

### Install Utilities
* run `./scripts/setup-cluster.sh`
* run `helm upgrade --install cert-issuer ./charts/cert-issuer --set email=you@example.com`

### Enable your Domain Name
* find the new load balancer created in the DO UI
* set that IP address in your DNS configuration, using a wildcard (e.g. `*.example.com`)

## Backups
I'm currently using a homegrown solution to manage `VolumeSnapshots`.
Code and documentation forthcoming. Stay tuned!

## Install Apps
Follow the instructions below to install one of the applications.

### HackMD
```
export HACKMD_POSTGRESS_PASSWORD=foobar
export HACKMD_HOST=hackmd.example.com
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
helm upgrade --install lychee-4 charts/lychee/ --namespace lychee-4 \
  --set ingress.host=$LYCHEE_HOST \
  --set mysql.root.password=$LYCHEE_DB_PASSWORD \
  --set mysql.db.password=$LYCHEE_DB_PASSWORD
```

### rocketchat
```
reckoner plot apps/rocketchat/course.yaml --helm-args \
  --set=mongodb.mongodbPassword=$ROCKETCHAT_PASSWORD,mongodb.mongodbRootPassword=$ROCKETCHAT_PASSWORD
```

### polaris
Polaris runs some basic health checks on your applications
```
reckoner plot apps/polaris/course.yaml
```

