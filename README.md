# Local cluster

```
sudo kind create cluster --config cluster.yaml
export KUBECONFIG="$(kind get kubeconfig-path --name="kind")"
export TILLER_NAMESPACE=tiller
k apply -f ./tiller/config.yaml
helm init --service-account tiller
```

# Util
```
reckoner plot util/nginx-ingress/course.yaml
```

# Apps
```
reckoner plot apps/polaris/course.yaml
k apply -f ./apps/polaris/ingress.yaml
```
