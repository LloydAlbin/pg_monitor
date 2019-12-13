# timescaledb

PostgreSQL TimescaleDB server for creating our Reports database.

* [TimescaelDB](https://www.timescale.com/products) - Timescale Database
* init_timescaledb.sql - Script to create a fresh Reports timescale database
* upgrade.sql - Script to upgrade your Reports timescale database with new features

You may either use a standard PostgreSQL database with the TimescaleDB extension installed, use the TiemscaleDB docker image, or even use the TimescaleDB Cloud edition.

## Building Custom Installation

In my case, I needed to rebuild the TimescaleDB docker image to include LDAP support. This was more complex as the TimescaleDB docker is based on the PostgreSQL alpine linux. First I needed to rebuild the PostgreSQL alpine linux to have LDAP support and then rebuild the TimescaleDB using this new PostgreSQL alpine linux with LDAP support.

See Instructions in the custom [README.md](custom/README.md)

## Installation

### Install on Docker

The instructions for [installing your TimescaleDB](https://docs.timescale.com/latest/getting-started/installation/docker/installation-docker).

### Install on Kubernetes

You should edit the PVC to use the StorageClass that you wish to use, such as NetApp storage, S3 storagem etc. The LocalStorage is included for doing a self contained and complete kubernetes test.

You will need to customize the following yaml files:

* pg-monitor-timescaledb-pvc.yaml for setting size, location, StorageClass for the PVC.
* pg-monitor-timescaledb-secret.yaml for setting the postgres superuser password. The password needs to be [base64 encoded](https://www.base64encode.org/).
* pg-monitor-timescaledb-service.yaml for setting the targetPort (converts Port 5432 to 5432) and nodePort (converts Port 5432 to 30002)
* pg-monitor-timescaledb-deployment.yaml file for setting the postgres password / secrets, etc.

### Install Official Kubernetes

```bash
# Example for Standard Docker Image
# kubectl apply -f ~/pg_monitor/timescaledb/kubernetes/pg-monitor-timescaledb-pvc.yaml
kubectl apply -f ~/pg_monitor/timescaledb/kubernetes/pg-monitor-timescaledb-secret.yaml
kubectl apply -f ~/pg_monitor/timescaledb/kubernetes/pg-monitor-timescaledb-service.yaml
kubectl apply -f ~/pg_monitor/timescaledb/kubernetes/pg-monitor-timescaledb-deployment.yaml
```

### Install Custom Kubernetes

```bash
# Example for Custom Docker Image
# kubectl apply -f ~/pg_monitor/timescaledb/kubernetes/pg-monitor-timescaledb-pvc.yaml
kubectl apply -f ~/pg_monitor/timescaledb/kubernetes/pg-monitor-timescaledb-secret.yaml
kubectl apply -f ~/pg_monitor/timescaledb/kubernetes/pg-monitor-timescaledb-service.yaml
kubectl apply -f ~/pg_monitor/timescaledb/custom/kubernetes/pg-monitor-timescaledb-deployment.yaml
```

### Loading the starting database

```bash
psql -h <cluster_name> -d postgres -p 30002 -U postgres -c "CREATE ROLE grafana WITH PASSWORD '<password>' IN ROLE pg_monitor;"
psql -h <cluster_name> -d postgres -p 30002 -U postgres -f ~/pg_monitor/timescaledb/init_timescaledb.sql
```

## Upgrade

The official instructions for [upgrading your TimescaleDB](https://docs.timescale.com/latest/using-timescaledb/update-db).

For upgrading an in use deployment, here is an easy way to do it.

```bash
kubectl delete -f ~/pg_monitor/timescaledb/custom/kubernetes/pg-monitor-timescaledb-deployment.yaml
#Edit pg-monitor-timescaledb-deployment.yaml and Update version number such as 1.2.2 to 1.5.1
#        #image: lloydalbin/timescaledb:1.2.2-pg11
#        image: lloydalbin/timescaledb:1.5.1-pg11
kubectl apply -f ~/pg_monitor/timescaledb/custom/kubernetes/pg-monitor-timescaledb-deployment.yaml

kubectl get all
NAME                                      READY   STATUS    RESTARTS   AGE
pod/pg-monitor-timescaledb-59f67889cc-wkf9g       1/1     Running   0          9m26s

kubectl exec -ti pg-monitor-timescaledb-59f67889cc-wkf9g -- psql -U postgres -d postgres -c 'ALTER EXTENSION timescaledb UPDATE;'
kubectl exec -ti pg-monitor-timescaledb-59f67889cc-wkf9g -- psql -U postgres -d pg_monitor_db -c 'ALTER EXTENSION timescaledb UPDATE;'
```

## Applying Enterprise TimescaleDB License

```sql
ALTER SYSTEM SET timescaledb.license_key='<license_key>';

-- Reload your PostgreSQL configs
SELECT pg_reload_conf();
```

## TimescaleDB Documentation

[TimescaleDB Documentation](https://docs.timescale.com/latest/main)

## Enterprise TimescaleDB License

[Emterprise TimescaleDB](https://docs.timescale.com/latest/getting-started/exploring-enterprise)

## Restoring your TimescaleDB from Backup

[Restoring from Backup](https://docs.timescale.com/latest/using-timescaledb/backup)
