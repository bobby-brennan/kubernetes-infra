#! /bin/bash
set -e

source `dirname "$0"`/util.sh

idx=0
while read -r line; do
  idx=$(( $idx + 1))
  if [ $idx -eq 1 ]; then
    continue
  fi
  id=$(get_string "${line}" 1)
  echo "patching $id"
  kubectl patch pv $id -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
done < <(kubectl get pv -A)

idx=0
while read -r line; do
  idx=$(( $idx + 1))
  if [ $idx -eq 1 ]; then
    continue
  fi
  ns=$(get_string "${line}" 1)
  id=$(get_string "${line}" 2)
  echo "patching pvc $ns/$id"
  kubectl patch pvc $id -n $ns -p '{"metadata": {"annotations": {"backup.kubernetes.io/deltas": "P1D P3D P7D P30D"}}}'
done < <(kubectl get pvc -A)
