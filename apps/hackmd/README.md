## Installation

For backup and restore to work, Photon must be installed.
```bash
k apply -f ./apps/hackmd/snapshotgroup.yaml
reckoner plot ./apps/hackmd/course.yaml
```

## Working on 1.16
> This does not appear to be the case any longer...working in namespace notepad

The hackmd chart doesn't work out of the box on 1.16. You'll need to

* Copy `values` out of `course.yaml`
* fill out env variables
* `helm template hackmd stable/hackmd -f values.yaml > hackmd.yaml`
* edit `hackmd.yaml`
  * on the Postgresql Deployment:
    * change `extensions/v1beta1` to `apps/v1`
    * change spec to look like:
```yaml
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hackmd-postgresql
      release: hackmd-postgresql
  strategy:
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: hackmd-postgresql
        release: hackmd-postgresql
    spec: // original spec
```
* change the selector on the svc to `app: hackmd-postgresql`
* `k apply -f hackmd.yaml -n hackmd`
