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
  kubectl patch pv $id -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
done < <(kubectl get pv)

