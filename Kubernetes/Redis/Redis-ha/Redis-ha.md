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
  
  
  # Helm output - ha 
  
  [kube@comlnx91 redis-ha]$ helm install --name redis1 stable/redis-ha --namespace redis --set exporter.enabled=true --set exporter.serviceMonitor.enabled=true --set exporter.serviceMonitor.namespace=redis --set haproxy.enabled=true --set haproxy.metrics.enabled=true --set haproxy.metrics.serviceMonitor.enabled=true --set persistentVolume.enabled=false --set haproxy.hardAntiAffinity=false --set sentinel.hardAntiAffinity=false --set haproxy.readOnly.enabled=true 

NAME:   redis1 

LAST DEPLOYED: Thu Feb  6 09:45:50 2020 

NAMESPACE: redis 

STATUS: DEPLOYED 

 

RESOURCES: 

==> v1/ConfigMap 

NAME                       DATA  AGE 

redis1-redis-ha-configmap  5     <invalid> 

 

==> v1/Deployment 

NAME                     READY  UP-TO-DATE  AVAILABLE  AGE 

redis1-redis-ha-haproxy  0/3    3           0          <invalid> 

 

==> v1/Pod(related) 

NAME                                      READY  STATUS       RESTARTS  AGE 

redis1-redis-ha-haproxy-858c4d47c7-6hk9q  0/1    Pending      0         <invalid> 

redis1-redis-ha-haproxy-858c4d47c7-bzchs  0/1    Init:0/1     0         <invalid> 

redis1-redis-ha-haproxy-858c4d47c7-zjgrd  0/1    Init:0/1     0         <invalid> 

redis1-redis-ha-server-0                  0/3    Init:0/1     0         <invalid> 

redis1-redis-ha-server-1                  0/3    Terminating  0         4m52s 

 

==> v1/Role 

NAME             AGE 

redis1-redis-ha  <invalid> 

 

==> v1/RoleBinding 

NAME             AGE 

redis1-redis-ha  <invalid> 

 

==> v1/Service 

NAME                        TYPE       CLUSTER-IP     EXTERNAL-IP  PORT(S)                      AGE 

redis1-redis-ha             ClusterIP  None           <none>       6379/TCP,26379/TCP,9121/TCP  <invalid> 

redis1-redis-ha-announce-0  ClusterIP  10.104.224.40  <none>       6379/TCP,26379/TCP,9121/TCP  <invalid> 

redis1-redis-ha-announce-1  ClusterIP  10.109.243.65  <none>       6379/TCP,26379/TCP,9121/TCP  <invalid> 

redis1-redis-ha-announce-2  ClusterIP  10.100.56.95   <none>       6379/TCP,26379/TCP,9121/TCP  <invalid> 

redis1-redis-ha-haproxy     ClusterIP  10.97.135.202  <none>       6379/TCP,6380/TCP,9101/TCP   <invalid> 

 

==> v1/ServiceAccount 

NAME                     SECRETS  AGE 

redis1-redis-ha          1        <invalid> 

redis1-redis-ha-haproxy  1        <invalid> 

 

==> v1/ServiceMonitor 

NAME                     AGE 

redis1-redis-ha          <invalid> 

redis1-redis-ha-haproxy  <invalid> 

 

==> v1/StatefulSet 

NAME                    READY  AGE 

redis1-redis-ha-server  0/3    <invalid> 

 

 

NOTES: 

Redis can be accessed via port 6379 and Sentinel can be accessed via port 26379 on the following DNS name from within your cluster: 

redis1-redis-ha.redis.svc.cluster.local 

 

To connect to your Redis server: 

1. Run a Redis pod that you can use as a client: 

 

   kubectl exec -it redis1-redis-ha-server-0 sh -n redis 

 

2. Connect using the Redis CLI: 

 

  redis-cli -h redis1-redis-ha.redis.svc.cluster.local 
 
 
 ## Helm -output
 
 [kube@comlnx91 ~]$ helm install --name redis1 stable/redis --namespace redis --set cluster.enabled=true --set master.persistence.enabled=false --set usePassword=false --set master.disableCommands="" --set metrics.enabled=true --set metrics.serviceMonitor.enabled=true --set metrics.serviceMonitor.namespace=logging 

 

NAME:   redis1 

LAST DEPLOYED: Fri Jan 10 10:44:15 2020 

NAMESPACE: redis 

STATUS: DEPLOYED 

 

RESOURCES: 

==> v1/ConfigMap 

NAME           DATA  AGE 

redis1         3     <invalid> 

redis1-health  6     <invalid> 

 

==> v1/Pod(related) 

NAME             READY  STATUS       RESTARTS  AGE 

redis1-master-0  0/2    Terminating  0         <invalid> 

redis1-slave-0   0/2    Pending      0         <invalid> 

 

==> v1/Service 

NAME             TYPE       CLUSTER-IP      EXTERNAL-IP  PORT(S)   AGE 

redis1-headless  ClusterIP  None            <none>       6379/TCP  <invalid> 

redis1-master    ClusterIP  10.110.29.46    <none>       6379/TCP  <invalid> 

redis1-metrics   ClusterIP  10.97.7.46      <none>       9121/TCP  <invalid> 

redis1-slave     ClusterIP  10.102.222.139  <none>       6379/TCP  <invalid> 

 

==> v1/ServiceMonitor 

NAME    AGE 

redis1  <invalid> 

 

==> v1/StatefulSet 

NAME           READY  AGE 

redis1-master  0/1    <invalid> 

redis1-slave   0/2    <invalid> 

 

 

NOTES: 

** Please be patient while the chart is being deployed ** 

Redis can be accessed via port 6379 on the following DNS names from within your cluster: 

 

redis1-master.redis.svc.cluster.local for read/write operations 

redis1-slave.redis.svc.cluster.local for read-only operations 

 

 

 

To connect to your Redis server: 

 

1. Run a Redis pod that you can use as a client: 

 

   kubectl run --namespace redis redis1-client --rm --tty -i --restart='Never' \ 

 

   --image docker.io/bitnami/redis:5.0.5-debian-9-r169 -- bash 

 

2. Connect using the Redis CLI: 

   redis-cli -h redis1-master 

   redis-cli -h redis1-slave 

 

To connect to your database from outside the cluster execute the following commands: 

 

    kubectl port-forward --namespace redis svc/redis1-master 6379:6379 & 

    redis-cli -h 127.0.0.1 -p 6379 
