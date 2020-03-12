## Working on 1.16

The hackmd chart doesn't work out of the box on 1.16. You'll need to

* Copy `values` out of `course.yaml`
* `helm template hackmd stable/hackmd -f values.yaml > deploy-hackmd.yaml`
* edit `deploy-hackmd.yaml`
  * on the Postgresql Deployment:
    * change `extensions/v1beta1` to `apps/v1`
    * change spec to look like:
```yaml
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hackmd
      release: hackmd
  strategy:
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: hackmd
        release: hackmd
```
* `k apply -f deploy-hackmd.yaml -n hackmd`
