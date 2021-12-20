# Troubleshooting PUBSUB 

 

1.  NiFi IP 

 

kubectl get pods -n commerce -o wide | grep nifi 

  

2. Redis commands 

  

kubectl exec -it -n redis redis-master-0 -- bash 

 

1. redis-cli pubsub channels 

2. redis-cli client list type pubsub 

4. redis-cli pubsub numsub "{cache-ntedevauth-services/cache/nifi/Wait}-invalidation" 

 

5. redis-cli --csv SUBSCRIBE "{cache-ntedevauth-services/cache/nifi/Wait}-invalidation" 

 

 
PUBSUB CHANNELS from NIFI 

1) "{cache-demoqalive-services/cache/WCNifiDistributedMapCache}-invalidation" 

2) "{cache-demoqaauth-services/cache/WCNifiDistributedMapCache}-invalidation" 

3) "{cache-demoqalive-services/cache/nifi/NLP}-invalidation" 

4) "{cache-demoqaauth-services/cache/nifi/workspace/Wait}-invalidation" 

5) "{cache-demoqalive-services/cache/nifi/Wait}-invalidation" 

6) "{cache-demoqaauth-services/cache/nifi/Wait}-invalidation" 

7) "{cache-demoqaauth-services/cache/nifi/NLP}-invalidation" 

 

 
TRACE: 
<logger name="com.hcl.commerce.cache" level="TRACE" /> 

<logger name="org.redisson" level="TRACE" /> 

 

JAVACORE ON NIFI - LOOK FOR redisson- threads 

 

 

 

DEBUG c.hcl.commerce.cache.remote.HCLCache.publishToCacheTopic:3523 - ENTRY inv-cache-dep:{"wait":"auth.reindex-DatabaseCategoryStage1d-6970--1-3074457345616676718-i-0b579d9c-1199-4c04-a9f7-ea61a0fdcf13","environment":"auth","connector":"auth.reindex","catalog":"3074457345616676718","run":"i-0b579d9c-1199-4c04-a9f7-ea61a0fdcf13","language":"-1","store":"6970","flow":"DatabaseCategoryStage1d"} 

 

2021-10-22T17:01:17.804Z [redisson-3-7] [] DEBUG c.h.c.c.r.InvalidationListenerToMessageListenerProxy.onMessage:33 - ENTRY {cache-ntedevauth-services/cache/nifi/Wait}-invalidation [p:ntedevnifi-app-54b498d9c7-t7mz8;t:1634922077802]> inv-cache-dep:{"wait":"auth.reindex-DatabaseCategoryStage1d-6970--1-3074457345616676718-i-0b579d9c-1199-4c04-a9f7-ea61a0fdcf13","environment":"auth","connector":"auth.reindex","catalog":"3074457345616676718","run":"i-0b579d9c-1199-4c04-a9f7-ea61a0fdcf13","language":"-1","store":"6970","flow":"DatabaseCategoryStage1d"} 

 

2021-10-22T17:01:17.804Z [redisson-3-7] [] DEBUG c.hcl.commerce.cache.remote.HCLCache.onMessage:3724 - services/cache/nifi/Wait invalidation message ignored (message not null): [p:ntedevnifi-app-54b498d9c7-t7mz8;t:1634922077802]> inv-cache-dep:{"wait":"auth.reindex-DatabaseCategoryStage1d-6970--1-3074457345616676718-i-0b579d9c-1199-4c04-a9f7-ea61a0fdcf13","environment":"auth","connector":"auth.reindex","catalog":"3074457345616676718","run":"i-0b579d9c-1199-4c04-a9f7-ea61a0fdcf13","language":"-1","store":"6970","flow":"DatabaseCategoryStage1d"} 

2021-10-22T17:01:17.804Z [redisson-3-7] [] DEBUG c.hcl.commerce.cache.remote.HCLCache.onMessage:3734 - RETURN 

DEBUG c.h.c.c.r.InvalidationListenerToMessageListenerProxy.onMessage:33 - ENTRY {cache-ntedevauth-services/cache/nifi 

 

System.out.println("Listeners:"+redisson.getTopic("{cache-demoqalivesbaseCache}-invalidation", StringCodec.INSTANCE ).countListeners()); 

 

 

 

 
