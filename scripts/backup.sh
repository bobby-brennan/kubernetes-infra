#! /bin/bash
set -e

source `dirname "$0"`/util.sh

set -euo pipefail
cur_directory=$(pwd)

rm -rf ~/k8s-backup/*
now=`date +%s`
mkdir -p ~/k8s-backup/$now

idx=0
kubectl get pv | while read line ; do
  idx=$(( $idx + 1))
  if [ $idx -eq 1 ]; then
    continue
  fi

  name=$(get_string "${line}" 6)
  name=${name/\//.}
  id=$(get_string "${line}" 1)

  cd ~/kind-disk/$id
  sudo zip -r ~/k8s-backup/$now/$name.zip . -i \*
done

cd $cur_directory
/usr/local/bin/aws2 s3 sync ~/k8s-backup/ s3://$S3_BACKUP_BUCKET --profile k8s-upload-backup
echo -e '\n\n'"Created backup snapshot $now"'\n\n'
