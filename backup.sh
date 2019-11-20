#! /bin/bash
set -euo pipefail
mkdir -p ~/k8s-backup/
sudo zip -r ~/k8s-backup/`date +%s`.zip ~/kind-disk/
/usr/local/bin/aws2 s3 sync ~/k8s-backup/ s3://bb-kubernetes-backups --profile k8s-upload-backup
