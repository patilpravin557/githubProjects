 

https://github.com/bitnami/charts/tree/master/bitnami/redis 

 

Single server redis 
helm repo add bitnami https://charts.bitnami.com/bitnami 

helm install  redis bitnami/redis --namespace redis --set cluster.enabled=false --set master.persistence.enabled=false --set usePassword=false  --set master.disableCommands="" --set metrics.enabled=true --set metrics.serviceMonitor.enabled=true --set metrics.serviceMonitor.namespace=redis 

 

 

OLD!! 

=========================== 

https://github.com/helm/charts/tree/master/stable/redis 

 

Single server redis 

helm install --name redis1 stable/redis --namespace redis --set cluster.enabled=false --set master.persistence.enabled=false --set usePassword=false  --set master.service.type=NodePort --set master.service.nodePort=30379 --set master.disableCommands="" 

 

For Metrics add: 

--set metrics.enabled=true --set metrics.serviceMonitor.enabled=true --set metrics.serviceMonitor.namespace=logging 

 

 

Multi server redis 

helm install --name redis1 stable/redis --namespace redis --set cluster.enabled=true --set master.persistence.enabled=false --set usePassword=false  --set master.disableCommands="" --set metrics.enabled=true --set metrics.serviceMonitor.enabled=true --set metrics.serviceMonitor.namespace=logging 

--set slave.persistence.enabled=false 

 

 

 

 
To delete: 
helm del --purge redis1 

 

Redis server/port: 10.190.67.115:30379 

 

 

[kube@comlnx91 ~]$ helm install --name redis1 stable/redis --namespace redis --set cluster.enabled=false --set master.persistence.enabled=false --set usePassword=false  --set master.service.type=NodePort --set master.service.nodePort=30379 

NAME:   redis1 

LAST DEPLOYED: Fri Dec  6 21:02:51 2019 

NAMESPACE: redis 

STATUS: DEPLOYED 

 

RESOURCES: 

==> v1/ConfigMap 

NAME           DATA  AGE 

redis1         3     <invalid> 

redis1-health  6     <invalid> 

 

==> v1/Pod(related) 

NAME             READY  STATUS             RESTARTS  AGE 

redis1-master-0  0/1    ContainerCreating  0         <invalid> 

 

==> v1/Service 

NAME             TYPE       CLUSTER-IP    EXTERNAL-IP  PORT(S)         AGE 

redis1-headless  ClusterIP  None          <none>       6379/TCP        <invalid> 

redis1-master    NodePort   10.99.77.253  <none>       6379:30379/TCP  <invalid> 

 

==> v1/StatefulSet 

NAME           READY  AGE 

redis1-master  0/1    <invalid> 

 

 

NOTES: 

** Please be patient while the chart is being deployed ** 

Redis can be accessed via port 6379 on the following DNS name from within your cluster: 

 

redis1-master.redis.svc.cluster.local 

 

 

 

To connect to your Redis server: 

 

1. Run a Redis pod that you can use as a client: 

 

   kubectl run --namespace redis redis1-client --rm --tty -i --restart='Never' \ 

 

   --image docker.io/bitnami/redis:5.0.5-debian-9-r169 -- bash 

 

2. Connect using the Redis CLI: 

   redis-cli -h redis1-master 

 

To connect to your database from outside the cluster execute the following commands: 

 

    export NODE_IP=$(kubectl get nodes --namespace redis -o jsonpath="{.items[0].status.addresses[0].address}") 

    export NODE_PORT=$(kubectl get --namespace redis -o jsonpath="{.spec.ports[0].nodePort}" services redis1-master) 

    redis-cli -h $NODE_IP -p $NODE_PORT 
