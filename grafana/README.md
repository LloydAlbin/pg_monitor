# grafana
grafana server. This is where we will be able to watch the status of our PostgreSQL servers.

## Installation

```bash
kubectl apply -f grafana-pvc.yaml
kubectl apply -f grafana-service.yaml
kubectl apply -f grafana-frontend.yaml
kubectl apply -f grafana-deployment.yaml
```

Edit the json files to replace ```SET TIME ZONE 'PST8PDT';``` with your specific time zone.

Load the data_sources.json file first to create the datasources.

If you are testing this in the Windows 10 docker/kubernetes, from the windows side you talk to localhost:30002 to access the database and 10.103.56.196:5432 to access from within the grafana kubernetes pod.

```bash
kubectl get service
NAME                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
kubernetes               ClusterIP   10.96.0.1       <none>        443/TCP          14d
pg-monitor-grafana       NodePort    10.103.48.29    <none>        3000:30000/TCP   29m
pg-monitor-timescaledb   NodePort    10.103.56.196   <none>        5432:30002/TCP   64m
```

## Upgrade

To upgrade your version of grafana, edit the grafana-deployment.yaml file, replacing the image line.

```bash
        #image: grafana/grafana:6.4.4
        image: grafana/grafana:6.5.0
```

Then apply the new deployment.

```bash
kubectl apply -f grafana-deployment.yaml
```
