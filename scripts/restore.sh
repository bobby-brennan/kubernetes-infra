#! /bin/bash
set -e

echo "Restoring $1 from snapshot at $2"
aws2 s3 copy s3://bb-kubernetes-backups/$2/$1.zip ./ --profile k8s-upload-backup
unzip $1.zip
