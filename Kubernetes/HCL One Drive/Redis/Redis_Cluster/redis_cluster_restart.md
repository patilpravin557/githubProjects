[root@com-kube-master redisc]# ll 
total 4 
-rw-r--r-- 1 root root 860 May 29 14:52 values.yaml 
[root@com-kube-master redisc]# 

 

 

helm delete redisc -n redisc 
 
kubectl create ns redisc 
 
helm install redisc bitnami/redis-cluster -f ./values.yaml -n redisc 

 

CLUSTER INFO 

==== 

for i in 0 1 2;do echo "member $i:" && kubectl exec -it -n redisc redisc-redis-cluster-$i -c redisc-redis-cluster -- redis-cli cluster info;done 

 

NODE 

==== 

for i in 0 1 2;do echo "member $i:" && kubectl exec -it -n redisc redisc-redis-cluster-$i -c redisc-redis-cluster -- redis-cli cluster nodes;done 

 

 

https://hclo365-my.sharepoint.com/personal/andres-voldman_hcl_com/_layouts/15/Doc.aspx?sourcedoc={26ef8526-39a4-47fe-8bc7-2330a7aba325}&action=edit&wd=target%28Redis.one%7C5a364aaa-a5c8-4b27-93ea-5196edbd96d8%2FRedis%20%28free%20helm%5C%29%20%20Utilities%7Cbb995591-bd35-4cea-99c2-29a013eecf1d%2F%29 

 

 

https://github01.hclpnp.com/commerce-dev/InstallGuides/tree/master/Redis/Cluster 
