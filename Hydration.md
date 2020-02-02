# [Work in Progress] - Migrating data to a new cluster

## Ghost
```
./scripts/backup.sh
TIMESTAMP=$(ls ~/k8s-backup)

mkdir ghost
tar -xvf ~/k8s-backup/$TIMESTAMP/ghost.ghost.tar.gz -C ./ghost
# find ghost pod name
k cp ghost ghost/ghost-5977f6ccdc-f4cc4:/bitnami/
rm -rf ghost

mkdir mariadb
tar -xvf ~/k8s-backup/$TIMESTAMP/ghost.data-ghost-mariadb-0.tar.gz -C ./mariadb
k cp mariadb ghost/ghost-mariadb-0:/bitnami/
rm -rf mariadb

k scale deploy --all --replicas=0
k scale statefulset --all --replicas=0
k scale deploy --all --replicas=1
k scale statefulset --all --replicas=1
```
