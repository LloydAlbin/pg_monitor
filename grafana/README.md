# grafana
grafana server. This is where we will be able to watch the status of our PostgreSQL servers.

```bash
kubectl apply -f grafana-pvc.yaml
kubectl apply -f grafana-service.yaml
kubectl apply -f grafana-frontend.yaml
kubectl apply -f grafana-deployment.yaml
```
