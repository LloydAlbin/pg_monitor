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
