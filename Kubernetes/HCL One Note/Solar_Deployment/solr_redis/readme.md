***************wrong password**************** 
I have no name!@redis-master-0:/$ redis-cli -a password 
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe. 
Warning: AUTH failed 
127.0.0.1:6379> keys * 
(error) NOAUTH Authentication required. 
127.0.0.1:6379> 

 
********************correct pwd*************** 
I have no name!@redis-master-0:/$ redis-cli -a passw0rd 
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe. 
127.0.0.1:6379> keys * 
1) "{cache-demoqaauth-services/cache/SearchQueryDistributedMapCache}-dep-&ALL&" 
2) "{cache-demoqaauth-services/cache/SearchFacetDistributedMapCache}-dep-&ALL&" 
3) "{cache_registry-demoqaauth}" 
4) "{cache_registry-demoqalive}" 
127.0.0.1:6379> 

 

kubectl get secret --namespace redis redis -o jsonpath="{.data.redis-password}" | base64 --decode 

passw0rd[root@com-kube-node1 ~]# 
