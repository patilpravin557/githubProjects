### Add the Helm Repo
helm repo add stable https://kubernetes-charts.storage.googleapis.com/

### Execute Helm Install
helm install prometheus stable/prometheus-operator -f values.yaml --namespace monitoring

### Update the serviceMonitorSelector
kubectl edit prometheus -n monitoring
```
Change service monitor Selector
From
  serviceMonitorSelector:
    matchLabels: 
To
serviceMonitorSelector: {}
```

### Use Port-Forwarding to access Grafana and Prometheus UI:
* kubectl port-forward -n monitoring service/prometheus-prometheus-oper-prometheus 12000:9090
* kubectl port-forward -n monitoring service/prometheus-grafana 12001:80
