# [Work in Progress] - Migrating data to a new cluster

Start by running:
```
./scripts/backup.sh
TIMESTAMP=$(ls ~/k8s-backup)
```

## Ghost
```
mkdir ghost
tar -xvf ~/k8s-backup/$TIMESTAMP/ghost.ghost.tar.gz -C ./ghost
# find ghost pod name
k cp ghost ghost/$POD:/bitnami/
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

## HackMD
```
mkdir uploads
tar -xvf ~/k8s-backup/$TIMESTAMP/hackmd.hackmd.tar.gz -C ./uploads
# find hackmd pod name
k cp uploads hackmd/$POD:/hackmd/public/
rm -rf uploads

mkdir postgresql
tar -xvf ~/k8s-backup/$TIMESTAMP/hackmd.hackmd-postgresql.tar.gz -C ./postgresql
k cp postgresql hackmd/hackmd-postgresql-0:/bitnami/
rm -rf postgresql

k scale deploy --all --replicas=0
k scale statefulset --all --replicas=0
k scale deploy --all --replicas=1
k scale statefulset --all --replicas=1
```
