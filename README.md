# Local cluster

### Create the cluster
```
sudo kind create cluster --config cluster.yaml
export KUBECONFIG="$(kind get kubeconfig-path --name="kind")"
sudo chown ubuntu $KUBECONFIG
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
### nginx-ingress
```
reckoner plot util/nginx-ingress/course.yaml
```
### cert-manager
```
reckoner plot util/cert-manager/course.yaml
k apply -f ./util/cert-manager/issuer.yaml
```

# Apps

### polaris
```
reckoner plot apps/polaris/course.yaml
k apply -f ./apps/polaris/ingress.yaml
```

### rocketchat
```
reckoner plot apps/rocketchat/course.yaml --helm-args --set=mongodb.mongodbPassword=YOUR_PASSWORD,mongodb.mongodbRootPassword=YOUR_PASSWORD
k apply -f ./apps/rocketchat/ingress.yaml
```

### HackMD
```
reckoner plot apps/hackmd/course.yaml
k apply -f ./apps/hackmd/ingress.yaml
```
