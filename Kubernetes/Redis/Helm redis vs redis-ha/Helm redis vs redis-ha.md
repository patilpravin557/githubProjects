# Helm redis vs redis-ha 

Redis 

 

https://github.com/helm/charts/tree/master/stable/redis 

 

Without sentinel (default) 
 

helm install --name redis1 stable/redis --namespace redis --set cluster.enabled=true --set master.persistence.enabled=false --set usePassword=false  --set master.disableCommands="" --set metrics.enabled=true --set metrics.serviceMonitor.enabled=true --set metrics.serviceMonitor.namespace=logging 

--set slave.persistence.enabled=false 
 

The chart  creates a master and slaves pods. 
There are two services: write > master, and read > slaves 

 

The slaves automatically replicate from the master. 
if a slave dies, other slaves will respond thru the service 
If the master dies, Kubernetes will respawn it. This is not true HA 
as the write service will be unavailable until the master is brought  
back by Kube. 
If persistence is not enabled, when the master comes back, it will 
have no data, while the slaves could still do, creating an inconsistency 
(note: I haven't tested persistence, but I tested killing the master 
and noticed this behavior in that the master had no data but the slaves did) 

 

With sentinel: 

 

From docs: "For read-only operations, access the service using port 6379. For write operations,  
it's necessary to access the Redis Sentinel cluster and query the current master using the command below (using redis-cli or similar:" 

 

So sentinel is better in that another running server will be promoted to master, but then Kubernetes 
wont automatically update the service to point to the new pod that was made master.  
This logic to find out the new master needs to be baked into the client which is problematic 
(SENTINEL get-master-addr-by-name <name of your MasterSet. Example: mymaster>) 

 

 

Redis-ha 

 

https://github.com/helm/charts/tree/master/stable/redis-ha 

 

helm install --name redis1 stable/redis-ha --namespace redis --set exporter.enabled=true --set exporter.serviceMonitor.enabled=true --set exporter.serviceMonitor.namespace=redis --set haproxy.enabled=true --set haproxy.metrics.enabled=true --set haproxy.metrics.serviceMonitor.enabled=true --set persistentVolume.enabled=false --set haproxy.hardAntiAffinity=false --set sentinel.hardAntiAffinity=false --set haproxy.readOnly.enabled=true 

 

(anti-affinity is disabled to allow testing on machines with only 2 nodes) 

 

 

 

 

 

 

 

 

 

 

 
