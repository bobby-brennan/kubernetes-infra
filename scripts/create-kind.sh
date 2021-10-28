#! /bin/bash
set -eo pipefail

kube_version="$1"
shift
if [ "x${kube_version}" == "x" ] ; then
  echo "Usage: $0 <kubernetes major.minor version>"
  echo "For example: $0 1.19"
  exit 1
fi
case "${kube_version}" in
  1.22)
    image='kindest/node:v1.22.0@sha256:b8bda84bb3a190e6e028b1760d277454a72267a5454b57db34437c34a588d047'
  ;;
  1.21)
    image='kindest/node:v1.21.1@sha256:69860bda5563ac81e3c0057d654b5253219618a22ec3a346306239bba8cfa1a6'
  ;;
  1.20)
    image='kindest/node:v1.20.7@sha256:cbeaf907fc78ac97ce7b625e4bf0de16e3ea725daf6b04f930bd14c67c671ff9'
  ;;
  1.19)
    image='kindest/node:v1.19.11@sha256:07db187ae84b4b7de440a73886f008cf903fcf5764ba8106a9fd5243d6f32729'
  ;;
  1.18)
    image='kindest/node:v1.18.19@sha256:7af1492e19b3192a79f606e43c35fb741e520d195f96399284515f077b3b622c'
  ;;
  1.17)
    image='kindest/node:v1.17.17@sha256:66f1d0d91a88b8a001811e2f1054af60eef3b669a9a74f9b6db871f2f1eeed00'
  ;;
  1.16)
    image='kindest/node:v1.16.15@sha256:83067ed51bf2a3395b24687094e283a7c7c865ccc12a8b1d7aa673ba0c5e8861'
  ;;
  1.15)
    image='kindest/node:v1.15.12@sha256:b920920e1eda689d9936dfcf7332701e80be12566999152626b2c9d730397a95'
  ;;
  1.14)
    image='kindest/node:v1.14.10@sha256:f8a66ef82822ab4f7569e91a5bccaf27bceee135c1457c512e54de8c6f7219f8'
  ;;
  *)
    echo "No image known for Kubernetes version ${kube_version}... Exiting."
    exit 1
  ;;
esac
echo Using kind to create Kube ${kube_version} cluster with image ${image}. . .

kind create cluster --config kind/cluster.yaml --image ${image} $@

kubectl apply -f kind/local-path-storage.yaml
kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false", "storageclass.beta.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true", "storageclass.beta.kubernetes.io/is-default-class":"true"}}}'

sleep 60

./scripts/setup-cluster.sh


