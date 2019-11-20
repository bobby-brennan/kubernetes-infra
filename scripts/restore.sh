#! /bin/bash
set -e

source `dirname "$0"`/util.sh

echo "Restoring $1 from snapshot at $2"
rm -rf restore
mkdir restore
aws2 s3 cp s3://$S3_BACKUP_BUCKET/$2/$1.zip ./restore/ --profile k8s-upload-backup
cd restore && unzip -q $1.zip && cd ..
rm restore/$1.zip

idx=0
while read -r line; do
  idx=$(( $idx + 1))
  if [ $idx -eq 1 ]; then
    continue
  fi

  name=$(get_string "${line}" 6)
  status=$(get_string "${line}" 5)
  name=${name/\//.}
  id=$(get_string "${line}" 1)
  if [[ $name == $1 ]] && [[ $status == "Bound" ]]; then
    echo "found $id"
    sudo mv ~/kind-disk/$id ~/kind-disk/backup-$id || true
    sudo mv ./restore ~/kind-disk/$id
    echo "Successfully restored $1 from $2 to PV $id"
    exit 0
  fi
done < <(kubectl get pv)

echo "PV not found!"
exit 1
