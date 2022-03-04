PV and pvc  

 

[root@com-kube-node1 redis-cluster]# pwd 

/root/solr_917/pvc/redis-cluster 

[root@com-kube-node1 redis-cluster]# ll 

total 24 

-rw-r--r-- 1 root root 217 Sep  1 12:20 pvc_redis_master0.yaml 

-rw-r--r-- 1 root root 217 Sep  1 12:23 pvc_redis_master1.yaml 

-rw-r--r-- 1 root root 217 Sep  1 12:25 pvc_redis_master2.yaml 

-rw-r--r-- 1 root root 296 Sep  1 12:20 pv_redis_master0.yaml 

-rw-r--r-- 1 root root 296 Sep  1 12:22 pv_redis_master1.yaml 

-rw-r--r-- 1 root root 296 Sep  1 12:24 pv_redis_master2.yaml 

[root@com-kube-node1 redis-cluster]# 

 

 

[root@com-kube-node1 redis-cluster]# kubectl get pv | grep redis 

redis-cluster-master0-pv                          10Gi       RWO            Retain           Bound       commerce/redis-cluster-redis-master-0                                                                               local-storage-redis                    5m19s 

redis-cluster-master1-pv                          10Gi       RWO            Retain           Bound       commerce/redis-cluster-redis-master-1                                                                               local-storage-redis                    2m30s 

redis-cluster-master2-pv                          10Gi       RWO            Retain           Bound       commerce/redis-cluster-redis-master-2                                                                               local-storage-redis                    18s 

[root@com-kube-node1 redis-cluster]# kubectl get pvc | grep redis 

redis-cluster-redis-master-0       Bound    redis-cluster-master0-pv          10Gi       RWO            local-storage-redis           5m15s 

redis-cluster-redis-master-1       Bound    redis-cluster-master1-pv          10Gi       RWO            local-storage-redis           2m30s 

redis-cluster-redis-master-2       Bound    redis-cluster-master2-pv          10Gi       RWO            local-storage-redis           19s 

[root@com-kube-node1 redis-cluster]# 

 

 

 

Install cluster redis 

[root@com-kube-node1 ~]# pwd 

/root 

helm install redis bitnami/redis-cluster -f redis_cluster_values.yaml -n redis 

 

CB testing  

 

Delete pod it will change the ip 

 

[root@com-kube-node1 ~]# kubectl delete pod redis-redis-cluster-0 -n redis 

pod "redis-redis-cluster-0" deleted 

[root@com-kube-node1 ~]# kubectl get pods -n redis -o wide 

NAME                    READY   STATUS     RESTARTS   AGE   IP                NODE                                NOMINATED NODE   READINESS GATES 

redis-redis-cluster-0   0/2     Init:0/1   0          4s    192.168.6.252     comp-3751-1                         <none>           <none> 

redis-redis-cluster-1   2/2     Running    0          11m   192.168.255.27    comp-3750-1                         <none>           <none> 

redis-redis-cluster-2   2/2     Running    0          12m   192.168.152.188  

 

Run the cluster nodes commands in each node, newly added node will not available on cluster 

 

So fix the cluster using below steps 

 

Fixing Cluster 
 

a)  List all nodes 

for i in 0 1 2;do echo "member $i:" && kubectl exec -it -n redisc redisc-redis-cluster-$i -c redisc-redis-cluster -- redis-cli cluster nodes;done 

 

b) forget the failed node (as delete changed ip) 

for i in 0 1 2;do echo "member $i:" && kubectl exec -it -n redisc redisc-redis-cluster-$i -c redisc-redis-cluster -- redis-cli cluster forget f89b3dcf51d192879f412ed83fd8a5007c82a006;done 

 

c) get ip of new node 

kubectl get pods -n redisc -o wide 

 

d) run meet 

kubectl exec -it -n redisc redisc-redis-cluster-2 -c redisc-redis-cluster -- redis-cli cluster meet 192.168.252.231 6379 

 

e) check nodes again 

for i in 0 1 2;do echo "member $i:" && kubectl exec -it -n redisc redisc-redis-cluster-$i -c redisc-redis-cluster -- redis-cli cluster nodes;done 

 

f) assign slots to new node  

 

kubectl exec -it -n redisc redisc-redis-cluster-2 -c redisc-redis-cluster -- bash 

 

for slot in {0..5460}; do redis-cli CLUSTER ADDSLOTS $slot > /dev/null; done; 

redis-cli cluster slots 

redis-cli cluster info 

 

g) 

for i in 0 1 2;do echo "member $i:" && kubectl exec -it -n redisc redisc-redis-cluster-$i -c redisc-redis-cluster -- redis-cli cluster info;done 

 

 

9/1/21 16:58:59:151 GMT] 00000077 CircuitBreake W com.hcl.commerce.cache.remote.CircuitBreaker setOutageMode() Cache services/cache/WCSearchFacetDistributedMapCache continues in outage mode 
[9/1/21 16:59:00:259 GMT] 00000077 CircuitBreake W com.hcl.commerce.cache.remote.CircuitBreaker setOutageMode() Cache services/cache/SearchSystemDistributedMapCache continues in outage mode 
[9/1/21 16:59:00:259 GMT] 00000075 CircuitBreake W com.hcl.commerce.cache.remote.CircuitBreaker setOutageMode() Cache services/cache/WCRESTTagDistributedMapCache continues in outage mode 
[9/1/21 16:59:00:259 GMT] 00000074 CircuitBreake W com.hcl.commerce.cache.remote.CircuitBreaker setOutageMode() Cache services/cache/WCUserAddressDistributedMapCache continues in outage mode 
[9/1/21 16:59:26:663 GMT] 00000077 CircuitBreake W com.hcl.commerce.cache.remote.CircuitBreaker setOutageMode() Cache services/cache/WCSearchMerchandisingDistributedMapCache continues in outage mode 
[9/1/21 16:59:27:863 GMT] 00000078 CircuitBreake W com.hcl.commerce.cache.remote.CircuitBreaker setOutageMode() Cache services/cache/WCMemberGroupDistributedMapCache continues in outage mode 
[9/1/21 16:59:29:655 GMT] 00000077 CircuitBreake W com.hcl.commerce.cache.remote.CircuitBreaker setOutageMode() Cache services/cache/WCStoreDistributedMapCache continues in outage mode 
[9/1/21 16:59:56:757 GMT] 00000078 CircuitBreake W com.hcl.commerce.cache.remote.CircuitBreaker setOutageMode() Cache services/cache/SearchCatHierarchyDistributedMapCache continues in outage mode 
  

[9/1/21 17:01:30:423 GMT] 00000078 RemoteOnlineE E com.hcl.commerce.cache.remote.maintenance.RemoteOnlineExpiredEntriesMaintenance performMaintenanceAndScheduleNextTask() services/cache/WCSessionDistributedMapCache Unable perform cache maintenance. Error: org.redisson.client.RedisNodeNotFoundException: Node for slot: 2647 hasn't been discovered yet. Check cluster slots coverage using CLUSTER NODES command. Increase value of retryAttempts and/or retryInterval settings. 
[9/1/21 17:01:30:858 GMT] 00000074 RemoteOnlineE E com.hcl.commerce.cache.remote.maintenance.RemoteOnlineExpiredEntriesMaintenance performMaintenanceAndScheduleNextTask() baseCache Unable perform cache maintenance. Error: org.redisson.client.RedisNodeNotFoundException: Node for slot: 4691 hasn't been discovered yet. Check cluster slots coverage using CLUSTER NODES command. Increase value of retryAttempts and/or retryInterval settings. 
[9/1/21 17:01:30:858 GMT] 00000074 CircuitBreake W com.hcl.commerce.cache.remote.CircuitBreaker setOutageMode() Cache baseCache continues in outage mode 
[9/1/21 17:01:32:669 GMT] 00000065 MasterPubSubC I org.redisson.connection.pool.ConnectionPool$1 lambda$run$0 1 connections initialized for 192.168.6.252/192.168.6.252:6379 
[9/1/21 17:01:32:677 GMT] 00000066 MasterConnect I org.redisson.connection.pool.ConnectionPool$1 lambda$run$0 24 connections initialized for 192.168.6.252/192.168.6.252:6379 
[9/1/21 17:01:32:678 GMT] 00000058 PubSubConnect I org.redisson.connection.pool.ConnectionPool$1 lambda$run$0 1 connections initialized for 192.168.6.252/192.168.6.252:6379 
[9/1/21 17:01:32:683 GMT] 0000006f ClusterConnec I org.redisson.cluster.ClusterConnectionManager lambda$addMasterEntry$5 master: redis://192.168.6.252:6379 added for slot ranges: [[0-5460]] 
[9/1/21 17:01:32:683 GMT] 0000006f SlaveConnecti I org.redisson.connection.pool.ConnectionPool$1 lambda$run$0 24 connections initialized for 192.168.6.252/192.168.6.252:6379 
[9/1/21 17:01:56:769 GMT] 00000077 RedisCacheCli I com.hcl.commerce.cache.remote.RedisCacheClient getScript( final String scriptName ) Loaded LUA Script: /com/hcl/commerce/cache/remote/scripts/maintain-online-expired.lua SHA: fa157954b7ebae1d77a5d8b979ea8df8c61a3bf8 

 
[9/1/21 17:01:56:771 GMT] 00000077 CircuitBreake I com.hcl.commerce.cache.remote.CircuitBreaker recordOperationSuccess() Cache services/cache/SearchCatHierarchyDistributedMapCache exiting outage mode 
[9/1/21 17:01:57:867 GMT] 00000075 CircuitBreake I com.hcl.commerce.cache.remote.CircuitBreaker recordOperationSuccess() Cache services/cache/WCSEOURLKeyword2URLTokenDistributedMapCache exiting outage mode 
[9/1/21 17:01:57:955 GMT] 00000078 CircuitBreake I com.hcl.commerce.cache.remote.CircuitBreaker recordOperationSuccess() Cache services/cache/DM_UserCache exiting outage mode 
[9/1/21 17:01:58:462 GMT] 00000077 CircuitBreake I com.hcl.commerce.cache.remote.CircuitBreaker recordOperationSuccess() Cache services/cache/WCMarketingDistributedMapCache exiting outage mode 
[9/1/21 17:01:59:069 GMT] 00000074 CircuitBreake I com.hcl.commerce.cache.remote.CircuitBreaker recordOperationSuccess() Cache services/cache/WCDistributedMapCache exiting outage mode 
[9/1/21 17:01:59:158 GMT] 00000051 CircuitBreake I com.hcl.commerce.cache.remote.CircuitBreaker recordOperationSuccess() Cache services/cache/WCSearchFacetDistributedMapCache exiting outage mode 
[9/1/21 17:02:00:265 GMT] 00000074 CircuitBreake I com.hcl.commerce.cache.remote.CircuitBreaker recordOperationSuccess() Cache services/cache/SearchSystemDistributedMapCache exiting outage mode 
[9/1/21 17:02:00:265 GMT] 00000077 CircuitBreake I com.hcl.commerce.cache.remote.CircuitBreaker recordOperationSuccess() Cache services/cache/WCUserAddressDistributedMapCache exiting outage mode 
[9/1/21 17:02:00:427 GMT] 00000078 CircuitBreake I com.hcl.commerce.cache.remote.CircuitBreaker recordOperationSuccess() Cache services/cache/WCSessionDistributedMapCache exiting outage mode 
[9/1/21 17:02:26:670 GMT] 00000078 CircuitBreake I com.hcl.commerce.cache.remote.CircuitBreaker recordOperationSuccess() Cache services/cache/WCSearchMerchandisingDistributedMapCache exiting outage mode 
[9/1/21 17:02:26:671 GMT] 00000051 CircuitBreake I com.hcl.commerce.cache.remote.CircuitBreaker recordOperationSuccess() Cache services/cache/WCRemoteDistributedMapCache exiting outage mode 
[9/1/21 17:02:27:869 GMT] 00000074 CircuitBreake I com.hcl.commerce.cache.remote.CircuitBreaker recordOperationSuccess() Cache services/cache/WCMemberGroupDistributedMapCache exiting outage mode 
[9/1/21 17:02:29:661 GMT] 00000077 CircuitBreake I com.hcl.commerce.cache.remote.CircuitBreaker recordOperationSuccess() Cache services/cache/WCStoreDistributedMapCache exiting outage mode 
[9/1/21 17:02:30:265 GMT] 00000075 CircuitBreake I com.hcl.commerce.cache.remote.CircuitBreaker recordOperationSuccess() Cache services/cache/WCRESTTagDistributedMapCache exiting outage mode 
[9/1/21 17:02:49:432 GMT] 00000074 HCLCache I com.hcl.commerce.cache.remote.HCLCache getRedisson() HCLCache services/cache/WCMemberGroupDistributedMapCache with Redis client default exiting outage mode 
[9/1/21 17:02:51:931 GMT] 00000077 HCLCache I com.hcl.commerce.cache.remote.HCLCache getRedisson() HCLCache services/cache/SearchSystemDistributedMapCache with Redis client default exiting outage mode 
[9/1/21 17:02:56:772 GMT] 00000075 HCLCache I com.hcl.commerce.cache.remote.HCLCache getRedisson() HCLCache services/cache/SearchCatHierarchyDistributedMapCache with Redis client default exiting outage mode 
[9/1/21 17:02:57:328 GMT] 00000074 CircuitBreake I com.hcl.commerce.cache.remote.CircuitBreaker recordOperationSuccess() Cache services/cache/WCMiscDistributedMapCache exiting outage mode 
[9/1/21 17:02:57:868 GMT] 00000051 HCLCache I com.hcl.commerce.cache.remote.HCLCache getRedisson() HCLCache services/cache/WCSEOURLKeyword2URLTokenDistributedMapCache with Redis client default exiting outage mode 
[9/1/21 17:02:57:956 GMT] 00000078 HCLCache I com.hcl.commerce.cache.remote.HCLCache getRedisson() HCLCache services/cache/DM_UserCache with Redis client default exiting outage mode 
[9/1/21 17:02:58:462 GMT] 00000077 HCLCache I com.hcl.commerce.cache.remote.HCLCache getRedisson() HCLCache services/cache/WCMarketingDistributedMapCache with Redis client default exiting outage mode 
[9/1/21 17:02:59:069 GMT] 00000075 CircuitBreake I com.hcl.commerce.cache.remote.CircuitBreaker recordOperationSuccess() Cache dmap/PriceCache exiting outage mode 
[9/1/21 17:02:59:069 GMT] 00000074 HCLCache I com.hcl.commerce.cache.remote.HCLCache getRedisson() HCLCache services/cache/WCDistributedMapCache with Redis client default exiting outage mode 
[9/1/21 17:02:59:159 GMT] 00000051 HCLCache I com.hcl.commerce.cache.remote.HCLCache getRedisson() HCLCache services/cache/WCSearchFacetDistributedMapCache with Redis client default exiting outage mode 
[9/1/21 17:03:00:266 GMT] 00000051 HCLCache I com.hcl.commerce.cache.remote.HCLCache getRedisson() HCLCache services/cache/WCUserAddressDistributedMapCache with Redis client default exiting outage mode 
[9/1/21 17:03:00:428 GMT] 00000078 HCLCache I com.hcl.commerce.cache.remote.HCLCache getRedisson() HCLCache services/cache/WCSessionDistributedMapCache with Redis client default exiting outage mode 
[9/1/21 17:03:00:862 GMT] 00000077 CircuitBreake I com.hcl.commerce.cache.remote.CircuitBreaker recordOperationSuccess() Cache baseCache exiting outage mode 
[9/1/21 17:03:05:631 GMT] 00000074 HCLCache I com.hcl.commerce.cache.remote.HCLCache getRedisson() HCLCache services/cache/WCRemoteDistributedMapCache with Redis client default exiting outage mode 
[9/1/21 17:03:23:333 GMT] 00000077 HCLCache I com.hcl.commerce.cache.remote.HCLCache getRedisson() HCLCache services/cache/WCRESTTagDistributedMapCache with Redis client default exiting outage mode 
[9/1/21 17:03:26:673 GMT] 00000051 HCLCache I com.hcl.commerce.cache.remote.HCLCache getRedisson() HCLCache services/cache/WCSearchMerchandisingDistributedMapCache with Redis client default exiting outage mode 
[9/1/21 17:03:29:661 GMT] 00000077 HCLCache I com.hcl.commerce.cache.remote.HCLCache getRedisson() HCLCache services/cache/WCStoreDistributedMapCache with Redis client default exiting outage mode 
[9/1/21 17:03:57:329 GMT] 00000074 HCLCache I com.hcl.commerce.cache.remote.HCLCache getRedisson() HCLCache services/cache/WCMiscDistributedMapCache with Redis client default exiting outage mode 
[9/1/21 17:03:59:071 GMT] 00000078 HCLCache I com.hcl.commerce.cache.remote.HCLCache getRedisson() HCLCache dmap/PriceCache with Redis client default exiting outage mode 
[9/1/21 17:04:00:532 GMT] 00000077 HCLCache I com.hcl.commerce.cache.remote.HCLCache getRedisson() HCLCache baseCache with Redis client default exiting outage mode 
