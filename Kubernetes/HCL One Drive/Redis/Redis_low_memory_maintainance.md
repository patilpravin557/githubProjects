docker start redis 

docker stop redis 

docker exec -it redis redis-cli 

docker exec redis redis-cli dbsize 

keys *size_m_1*WCT+?* 

scard  "{cache-demoqalive-services/loadtest/cache/size_xs_1}-dep-WCT+?" 

(integer) 0 

smembers "{cache-demoqalive-services/loadtest/cache/size_xs_1}-dep-WCT+SIZE_XS_1+010-005" 

  

  

docker exec redis redis-cli dbsize 

  

C:\Users\pravinprakash.patil>docker exec redis redis-cli dbsize 

3835239 

  

C:\Users\pravinprakash.patil>docker exec redis redis-cli dbsize 

3835239 

  

C:\Users\pravinprakash.patil>docker exec -it redis redis-cli 

127.0.0.1:6379> keys *size_xxs_1* 

(empty array) 

(2.58s) 

127.0.0.1:6379> keys *size_xxs_2* 

(empty array) 

(6.28s) 

127.0.0.1:6379> keys *size_m_3* 

  

  

  

127.0.0.1:6379> keys *size_xxs_1* 

(empty array) 

(2.58s) 

127.0.0.1:6379> keys *size_xxs_2* 

(empty array) 

(6.28s) 

127.0.0.1:6379> keys *size_m_3* 

  

  

http://ingest.demoqa.pravin.svt.hcl.com/connectors/auth.reindex/runs/i-341d6faf-e41e-4de4-94f9-9a8304f7d6a1?size=1000&type=summary%2Ctrace%2Clog&logSeverity=I%2CE%2CT&orderDate=asc 

  

127.0.0.1:6379>  keys *size_m_1*WCT+?* 

(empty array) 

(4.60s) 

127.0.0.1:6379>  keys *size_m_1* 

(empty array) 

(5.13s) 

127.0.0.1:6379>  keys *size_xs_1*WCT+?* 

(empty array) 

(4.18s) 

127.0.0.1:6379>  keys *size_xs_1* 

(empty array) 

(6.04s) 

127.0.0.1:6379> scard  "{cache-demoqalive-services/loadtest/cache/size_xs_1}-dep-WCT+?" 

(integer) 0 

(0.64s) 

127.0.0.1:6379> scard  "{cache-demoqalive-services/loadtest/cache/size_xs_1}-dep-WCT+SIZE_XS_1+100-005" 

(integer) 0 

127.0.0.1:6379> 

 

 

[2:07 AM] Andres Voldman 

for i in `seq 1 500000`; do echo "SET {​​​​​​​cache1}​​​​​​​KEY_$i VALUE_$i"; done | redis-cli --pipe -h hclcache -p 18279 -a passw0rd 

 

 

 

 

I have no name!@redisc-redis-cluster-0:/$  redis-cli info memory | grep huma 

used_memory_human:1.51G 

used_memory_rss_human:1.53G 

used_memory_peak_human:1.52G 

total_system_memory_human:31.26G 

used_memory_lua_human:55.00K 

used_memory_scripts_human:6.18K 

maxmemory_human:4.88G 

 
  

 

 

 

 

cd /root/setup/redis 

 
kubectl cp dump.rdb redis-master-0:/data/dump.rdb -n redis -c redis 
 

kubectl delete pod redis-master-0 -n redis 
 

kubectl exec -n redis redis-master-0 -c redis redis-cli dbsize 

 
kubectl exec -n redis redis-master-0 redis-cli info memory | grep human 
 

 
 
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version.  

Use kubectl exec [POD] -- [COMMAND] instead. 
Defaulting container name to redis. 
Use 'kubectl describe pod/redis-master-0 -n redis' to see all of the containers in this pod. 

 
used_memory_human:3.08G 

 
used_memory_rss_human:3.12G 
 

used_memory_peak_human:3.08G 
 

total_system_memory_human:31.26G 
 

used_memory_lua_human:42.00K 
 

used_memory_scripts_human:2.60K 
 

maxmemory_human:3.42G 

 

 

 

[1/27 7:02 PM] Andres Voldman 

In Lydia's DB some caches get up to 3k "naturally" 

  

[1/27 7:02 PM] Andres Voldman 

but also important, if you look at the memory .. 

  

[1/27 7:02 PM] Andres Voldman 

  

[1/27 7:03 PM] Pravin Prakash Patil 

its single redis ? mine is cluster does that makes a difference  

  

[1/27 7:03 PM] Andres Voldman 

single Redis 

  

[1/27 7:03 PM] Andres Voldman 

  

[1/27 7:03 PM] Andres Voldman 

She filled up the Redis memory 

  

[1/27 7:03 PM] Andres Voldman 

and the low memory maintenance maintained the memory under full 

  

[1/27 7:04 PM] Andres Voldman 

I did notice in that chart above (last one) that low_memory maintenance counts as expired too, because low memory process just expires entries 

  

[1/27 7:04 PM] Andres Voldman 

so I think we need to beef up your environment 
