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

The instructions for [installing your TimescaleDB](https://docs.timescale.com/latest/getting-started/installation/docker/installation-docker).

You will need to customize the following yaml files:

* reports-pvc.yaml for setting size, location, etc.
* reports-service.yaml for setting the targetPort (converts Port 5432 to 5432)
* reports-frontend.yaml for setting the nodePort (converts Port 5432 to 30002)
* reports-deploy.yaml file for setting the postgres password / secrets.

```bash
kubectl apply -f reports-pvc.yaml
kubectl apply -f reports-frontend.yaml
kubectl apply -f reports-service.yaml
kubectl apply -f reports-deploy.yaml
```
## Upgrade

The instructions for [upgrading your TimescaleDB](https://docs.timescale.com/latest/using-timescaledb/update-db).

For upgrading an in use deployment, here is an easy way to do it.

```bash
kubectl delete -f reports-deploy.yaml
#Edit reports-deploy.yaml and Update version number such as 1.2.2 to 1.5.1
#        #image: lloydalbin/timescaledb:1.2.2-pg11
#        image: lloydalbin/timescaledb:1.5.1-pg11
kubectl apply -f reports-deploy.yaml

kubectl get all
NAME                                      READY   STATUS    RESTARTS   AGE
pod/reports-59f67889cc-wkf9g       1/1     Running   0          9m26s

kubectl exec -ti reports-59f67889cc-wkf9g -- psql -U postgres -d postgres -c 'ALTER EXTENSION timescaledb UPDATE;'
kubectl exec -ti reports-59f67889cc-wkf9g -- psql -U postgres -d reports -c 'ALTER EXTENSION timescaledb UPDATE;'
```