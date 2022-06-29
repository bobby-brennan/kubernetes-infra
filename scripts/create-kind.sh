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
  1.24)
    image='kindest/node:v1.24.0@sha256:0866296e693efe1fed79d5e6c7af8df71fc73ae45e3679af05342239cdc5bc8e'
  ;;
  1.23)
    image='kindest/node:v1.23.6@sha256:b1fa224cc6c7ff32455e0b1fd9cbfd3d3bc87ecaa8fcb06961ed1afb3db0f9ae'
  ;;
  1.22)
    image='kindest/node:v1.22.9@sha256:8135260b959dfe320206eb36b3aeda9cffcb262f4b44cda6b33f7bb73f453105'
  ;;
  1.21)
    image='kindest/node:v1.21.12@sha256:f316b33dd88f8196379f38feb80545ef3ed44d9197dca1bfd48bcb1583210207'
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

if ping host.docker.internal -c 1; then
  echo "changing KUBECONFIG to point to parent's docker host"
  sed -i 's/127.0.0.1/host.docker.internal/g' $KUBECONFIG
fi

echo "created cluster, waiting for warmup"
sleep 30

./scripts/setup-cluster.sh


