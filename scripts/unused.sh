#! /bin/bash
set -e

source `dirname "$0"`/util.sh

for dir in ~/kind-disk/*; do
  pvName=$(basename $dir)
  kubectl get pv $pvName &> /dev/null || echo $pvName
done

