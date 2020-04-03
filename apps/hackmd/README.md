## Installation

For backup and restore to work, Photon must be installed.
```bash
k apply -f ./apps/hackmd/snapshotgroup.yaml
reckoner plot ./apps/hackmd/course.yaml
```

## Database Migration
```
k exec -it hackmd-postgresql-0 -- /bin/sh
pg_dumpall > backup.sql
# ctrl+d
k cp hackmd-postgresql-0:backup.sql ./backup.sql
# switch namespace
k cp ./backup.sql hackmd-postgresql-0:/tmp/backup.sql
k exec -it hackmd-postgresql-0 -- /bin/sh
psql -f /tmp/backup.sql postgres -U hackmd
```

