# Local cluster

## Dependencies
```
curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.6.0/kind-$(uname)-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/

pip install reckoner
```

## Start

### Create the cluster
```
kind create cluster --config cluster.yaml
export KUBECONFIG="$(kind get kubeconfig-path --name="kind")"
```

### Install Helm
```
export TILLER_NAMESPACE=tiller
k apply -f ./tiller/config.yaml
helm init --service-account tiller
```

### Enable storage
```
k apply -f local-path-storage.yaml
kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false", "storageclass.beta.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true", "storageclass.beta.kubernetes.io/is-default-class":"true"}}}'
```

# Required Utilities
This will install nginx-ingress, cert-manager, and metrics-server
```
reckoner plot util/course.yaml
```

# Apps

### polaris
```
reckoner plot apps/polaris/course.yaml
```

### rocketchat
```
reckoner plot apps/rocketchat/course.yaml --helm-args --set=mongodb.mongodbPassword=$YOUR_PASSWORD,mongodb.mongodbRootPassword=$YOUR_PASSWORD
k apply -f ./apps/rocketchat/ingress.yaml
```

### HackMD
```
reckoner plot apps/hackmd/course.yaml
```

### Ghost
```
reckoner plot apps/ghost/course.yaml --helm-args --set=ghostPassword=$APP_PASSWORD,mariadb.db.password=$APP_DATABASE_PASSWORD
k apply -f ./apps/ghost/ingress.yaml
```
