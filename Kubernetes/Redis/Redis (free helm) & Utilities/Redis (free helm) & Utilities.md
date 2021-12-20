# Redis (free helm) & Utilities 

https://github.com/bitnami/charts/tree/master/bitnami/redis-cluster 

 

kubectl create ns redisc 

helm install redisc bitnami/redis-cluster -f ./values.yaml -n redisc 

helm delete redisc -n redisc 

 

============================================== 

# kubectl create ns redisc 

# helm install redisc bitnami/redis-cluster -f ./values.yaml -n redisc 

# kubectl get all -n redisc -o wide 

cluster: 

  nodes: 3 

  replicas: 0 

usePassword: false 

useAOFPersistence: "no" 

resources: 

  limits: 

    cpu: "8" 

    memory: 12Gi 

  requests: 

    cpu: "2" 

    memory: 12Gi 

persistence: 

  enabled: false 

metrics: 

  enabled: true 

  serviceMonitor: 

    enabled: true 

    selector: 

      prometheus: kube-prometheus 

redis: 
  configmap: |- 

    maxmemory 11000mb 

    maxmemory-policy volatile-lru 

    slowlog-log-slower-than 10000 

    slowlog-max-len 512     

    latency-monitor-threshold 100 
    cluster-require-full-coverage no 
    appendonly no 
    save "" 

sysctlImage: 

  enabled: true 

  mountHostSys: true 

  command: 

    - /bin/sh 

    - -c 

    - |- 

      install_packages procps 

      sysctl -w net.core.somaxconn=10000 

      echo never > /host-sys/kernel/mm/transparent_hugepage/enabled 

============================================== 

 

Utilities 
 

yum -y install redis 
 
redis-benchmark -h redisc-redis-cluster-0.redisc-redis-cluster-headless.redisc.svc.cluster.local -p 6379 -t set -n 100000 -c 30 -d 500 
 
redis-cli -h redisc-redis-cluster-1.redisc-redis-cluster-headless.redisc.svc.cluster.local -p 6379 --latency-history 

 
 

 
Benchmark (cluster-0 to cluster-1) 

kubectl exec -it -n redisc redisc-redis-cluster-0 -c redisc-redis-cluster -- redis-benchmark -h redisc-redis-cluster-1.redisc-redis-cluster-headless.redisc.svc.cluster.local -p 6379 -t set -n 100000 -c 30 -d 500 

 

Latency (0 to 1) 

kubectl exec -it -n redisc redisc-redis-cluster-0 -c redisc-redis-cluster -- redis-cli -h redisc-redis-cluster-1.redisc-redis-cluster-headless.redisc.svc.cluster.local -p 6379 --latency-history 
 
 

Commands 

 

kubectl exec -it -n redisc redisc-redis-cluster-0 -c redisc-redis-cluster -- redis-cli keys '*-dep-&ALL&' 

kubectl exec -it -n redisc redisc-redis-cluster-1 -c redisc-redis-cluster -- redis-cli keys '*-dep-&ALL&' 

kubectl exec -it -n redisc redisc-redis-cluster-2 -c redisc-redis-cluster -- redis-cli keys '*-dep-&ALL&' 

 

 

Cache List 

==== 

for i in 0 1 2;do echo "member $i:" && kubectl exec -it -n redisc redisc-redis-cluster-$i -c redisc-redis-cluster -- redis-cli keys '*-dep-&ALL&';done 

 

CLUSTER INFO 

==== 

for i in 0 1 2;do echo "member $i:" && kubectl exec -it -n redisc redisc-redis-cluster-$i -c redisc-redis-cluster -- redis-cli cluster info;done 

 

NODE 

==== 

for i in 0 1 2;do echo "member $i:" && kubectl exec -it -n redisc redisc-redis-cluster-$i -c redisc-redis-cluster -- redis-cli cluster nodes;done 

 

 

FLUSHALL 

==== 

for i in 0 1 2;do echo "member $i:" && kubectl exec -it -n redisc redisc-redis-cluster-$i -c redisc-redis-cluster -- redis-cli flushall;done 
 
 

SLOWLOG LEN 

==== 

for i in 0 1 2;do echo "member $i:" && kubectl exec -it -n redisc redisc-redis-cluster-$i -c redisc-redis-cluster -- redis-cli slowlog len;done 

 

CONFIG TEST - FULL COVERAGE 

==== 

for i in 0 1 2;do echo "member $i:" && kubectl exec -it -n redisc redisc-redis-cluster-$i -c redisc-redis-cluster -- redis-cli config get cluster-require-full-coverage;done 
 

 

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

 

 

 

Connection in config map 
 
 

  redis_cfg.yaml: |- 

    # redis_cfg.yaml content read from values 

    clusterServersConfig: 

      idleConnectionTimeout: 10000 

      connectTimeout: 5000 

      timeout: 500 

      retryAttempts: 2 

      retryInterval: 500 

      subscriptionsPerConnection: 5 

      sslProvider: "JDK" 

      pingConnectionInterval: 0 

      keepAlive: true 

      tcpNoDelay: true 

      loadBalancer: !<org.redisson.connection.balancer.RoundRobinLoadBalancer> {} 

      slaveConnectionMinimumIdleSize: 24 

      slaveConnectionPoolSize: 64 

      failedSlaveReconnectionInterval: 3000 

      failedSlaveCheckInterval: 180000 

      masterConnectionMinimumIdleSize: 24 

      masterConnectionPoolSize: 64 

      subscriptionMode: "MASTER" 

      subscriptionConnectionMinimumIdleSize: 1 

      subscriptionConnectionPoolSize: 50 

      dnsMonitoringInterval: 5000 

      nodeAddresses: 

      - "redis://redisc-redis-cluster-0.redisc-redis-cluster-headless.redisc.svc.cluster.local:6379" 

      - "redis://redisc-redis-cluster-1.redisc-redis-cluster-headless.redisc.svc.cluster.local:6379" 

      - "redis://redisc-redis-cluster-2.redisc-redis-cluster-headless.redisc.svc.cluster.local:6379" 

      scanInterval: 5000 

    threads: 16 

    nettyThreads: 60 

    referenceEnabled: true 

    transportMode: "NIO" 

    lockWatchdogTimeout: 30000 

    keepPubSubOrder: true 

    decodeInExecutor: true 

    useScriptCache: false 

    minCleanUpDelay: 5 

    maxCleanUpDelay: 1800 

    addressResolverGroupFactory: !<org.redisson.connection.DnsAddressResolverGroupFactory> {} 
