#! /bin/bash
set -euo pipefail
mkdir -p ~/k8s-backup/
zip -r ~/k8s-backup/`date +%s`.zip ~/kind-disk/
aws2 s3 sync ~/k8s-backup/ s3://bb-kubernetes-backups --profile k8s-upload-backup
