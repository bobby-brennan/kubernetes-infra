set -e

name=$(kubectl get po -n lychee -oname)

kubectl exec -n lychee -it $name -- mkdir -p /uploads/big
kubectl exec -n lychee -it $name -- mkdir -p /uploads/thumb
kubectl exec -n lychee -it $name -- chown www-data /uploads/big
kubectl exec -n lychee -it $name -- chown www-data /uploads/thumb
