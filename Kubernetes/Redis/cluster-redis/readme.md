
# Clustered Redis with Helm

https://github.com/bitnami/charts/tree/master/bitnami/redis-cluster

```
kubectl create ns redisc
helm install redisc bitnami/redis-cluster -f ./values.yaml -n redisc
helm delete redisc -n redisc
```

## Sample commands

#### Cache List

Linux
```
for i in 0 1 2;do echo "member $i:" && kubectl exec -it -n redisc redisc-redis-cluster-$i -c redisc-redis-cluster -- redis-cli keys '*-dep-&ALL&';done
```
Powershell
```
for ($num = 0 ; $num -le 2; $num++) {echo "redisc redisc-redis-cluster-$num"; kubectl exec -it -n redisc redisc-redis-cluster-$num -c redisc-redis-cluster -- redis-cli keys '*-dep-&ALL&'}

```

#### Cluster Info
```
for i in 0 1 2;do echo "member $i:" && kubectl exec -it -n redisc redisc-redis-cluster-$i -c redisc-redis-cluster -- redis-cli cluster info;done
```

### Nodes
```
for i in 0 1 2;do echo "member $i:" && kubectl exec -it -n redisc redisc-redis-cluster-$i -c redisc-redis-cluster -- redis-cli cluster nodes;done
```

### Flushall 
```
for i in 0 1 2;do echo "member $i:" && kubectl exec -it -n redisc redisc-redis-cluster-$i -c redisc-redis-cluster -- redis-cli flushall;done
```

### Showlog Len
```
for i in 0 1 2;do echo "member $i:" && kubectl exec -it -n redisc redisc-redis-cluster-$i -c redisc-redis-cluster -- redis-cli slowlog len;done
```




