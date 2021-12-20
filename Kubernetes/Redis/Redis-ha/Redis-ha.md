# Redis HA

https://github.com/helm/charts/tree/master/stable/redis-ha 

 

 

helm del --purge redis1 

helm repo update 

helm fetch stable/redis-ha 

helm install --name redis1 stable/redis-ha --namespace redis --set exporter.enabled=true --set exporter.serviceMonitor.enabled=true --set exporter.serviceMonitor.namespace=redis --set haproxy.enabled=true --set haproxy.metrics.enabled=true --set haproxy.metrics.serviceMonitor.enabled=true --set persistentVolume.enabled=false --set hardAntiAffinity=false --set haproxy.hardAntiAffinity=false --set sentinel.hardAntiAffinity=false --set haproxy.readOnly.enabled=true 

helm list 

 

Note: I had to update servicemonitor component label because it was not matching. This is a bug in the helm 

 

 

Grafana: 
 

10225 

 

From <https://grafana.com/grafana/dashboards/10225>  

 

763 

 

https://grafana.com/grafana/dashboards/763 

 

 

https://www.haproxy.com/blog/haproxy-exposes-a-prometheus-metrics-endpoint/ 

 

 

============================================================================= 

 

1. Run a Redis pod that you can use as a client: 

 

   kubectl exec -it redis1-redis-ha-server-0 sh -n redis 

 

2. Connect using the Redis CLI: 

 

  redis-cli -h redis1-redis-ha.redis.svc.cluster.local 
