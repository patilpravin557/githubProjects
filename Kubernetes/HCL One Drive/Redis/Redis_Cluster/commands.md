volumePermissions: 

  enabled: false 

  image: 

    registry: docker.io 

    repository: bitnami/minideb 

    tag: buster 

    pullPolicy: IfNotPresent  

 

[root@comlnx91 redisc]# kubectl exec -it -n redisc redisc-redis-cluster-0 bash 

kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl kubectl exec [POD] -- [COMMAND] instead. 

Defaulting container name to redisc-redis-cluster. 

Use 'kubectl describe pod/redisc-redis-cluster-0 -n redisc' to see all of the containers in this pod. 

I have no name!@redisc-redis-cluster-0:/$ redis-cli 

127.0.0.1:6379> 

 

 

https://github.com/bitnami/charts/tree/master/bitnami/redis-cluster 

 

https://hclo365-my.sharepoint.com/personal/andres-voldman_hcl_com/_layouts/15/Doc.aspx?sourcedoc={26ef8526-39a4-47fe-8bc7-2330a7aba325}&action=edit&wd=target%28Redis.one%7C5a364aaa-a5c8-4b27-93ea-5196edbd96d8%2FRedis%20%28free%20helm%5C%29%20%20Utilities%7Cbb995591-bd35-4cea-99c2-29a013eecf1d%2F%29 

 

 

kubectl create ns redisc 

helm install redisc bitnami/redis-cluster -f ./values.yaml -n redisc 

helm delete redisc -n redisc 

 

 

Cache List 

==== 

for i in 0 1 2;do echo "member $i:" && kubectl exec -it -n redisc redisc-redis-cluster-$i -c redisc-redis-cluster -- redis-cli keys '*-dep-&ALL&';done 

 

CLUSTER INFO 

==== 

for i in 0 1 2;do echo "member $i:" && kubectl exec -it -n redisc redisc-redis-cluster-$i -c redisc-redis-cluster -- redis-cli cluster info;done 

 

NODE 

==== 

for i in 0 1 2;do echo "member $i:" && kubectl exec -it -n redisc redisc-redis-cluster-$i -c redisc-redis-cluster -- redis-cli cluster nodes;done 
