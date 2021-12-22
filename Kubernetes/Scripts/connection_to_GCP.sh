
## DB2

| | | 
|-|-|
| instance: | perf-cluster2-ingest-db2-1 |
| zone: |  us-east1-b |
| internal ip (fixed): | perf2db2 (10.142.0.73) |
| hardware: | e2-standard-16 (16 vCPUs, 64 GB memory) - 1TB SSD |

#### DB2 ssh

```
gcloud compute ssh perf-cluster2-ingest-db2-1 --zone us-east1-b
```

## Kubernetes cluster

> gcloud container clusters get-credentials perf-cluster2-ingest --zone us-east1-b --project commerce-product

### Node pools

| name | machine type | nodes | 
|-|-|- | 
| default-pool | e2-standard-8 ( 8 vcpu/32GB ) | 1 |
| elastic-pool | e2-standard-16 ( 16 vcpu/64GB ) | 3 | 
| nifi-pool | e2-standard-16 ( 16 vcpu/64GB ) | 1 |  

# Using Port-Forwarding to access servers
| tool | port-forward | URL | 
|-|-|- | 
| **Prometheus** | kubectl port-forward -n monitoring service/prometheus-kube-prometheus-prometheus 12000:9090  | http://localhost:12000 |
| **Grafana** | kubectl port-forward -n monitoring service/prometheus-grafana 12001:80 | http://localhost:12001 |
| **Kibana** | kubectl port-forward -n elastic service/kibana-kibana 12002:5601 | http://localhost:12002 |
| **Nifi** | kubectl port-forward -n commerce service/demoqanifi-app 12010:30600 | http://localhost:12010/nifi/ |
| **Ingest** | kubectl port-forward -n commerce service/demoqaingest-app 12011:30800 | http://localhost:12011/swagger-ui/index.html?url=/v3/api-docs#/ |





