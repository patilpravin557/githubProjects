# Opening the Cache Monitor 

Same as previous versions, the Cache Monitor cannot be opened in a load balanced port.  
The solution is to use kubectl port-forward to access port in one of the pods 

 Enable port forwarding to the crs-app pod 
 
kubectl port-forward POD_NAME -n commerce 8080:8080 
 

Configure Putty to tunnel 8080 to 8080 (or whatever local port you want) 

When connected to the Putty session, the Cache Monitor will be available under URL http://localhost:8080/cachemonitor  


## Monitoring Dynacache

Using the Cache Monitor for monitoring caching performance statistics is a poor approach. It requires you to connect to each machine individually and there is no automatic recording of statistics 

 

Even though WebSphere Dynacache does export some JMX objects, these sadly cannot be used for monitoring, as they expose methods and not attributed 

 

Dynacache Performance Monitor 

 

We are testing out the following technique for monitoring Dynacache 

 

We have developed a WAR (Web App) that uses JMX to query Cache statistics and, at regular intervals, prints the statistics in JSON format to the log 
 
https://github01.hclpnp.com/commerce-dev/performance-assets/tree/master/PerfMonitor 
 

The output of the tool looks as follows: 
 

{"type":"liberty_message","host":"LP1-US-51830221.PROD.HCLPNP.COM","ibm_userDir":"C:\/dev\/Liberty\/usr\/","ibm_serverName":"dynaTesting","message":"{\"RemoteUpdateNotifications\":0,\"GarbageCollectorInvalidationsFromDisk\":0,\"ObjectsReadFromDisk400K\":0,\"ObjectsDeleteFromDisk40K\":0,\"TemplateBasedInvalidationsFromDisk\":0,\"ExplicitInvalidationsFromDisk\":0,\"ObjectsWriteToDisk400K\":0,\"PushPullTableSize\":0,\"ExplicitInvalidationsRemote\":0,\"ObjectsWriteToDisk40K\":0,\"ObjectsWriteToDisk4000K\":0,\"ObjectsReadFromDisk\":0,\"DependencyIdBasedInvalidationsFromDisk\":0,\"OverflowInvalidationsFromDisk\":0,\"ObjectsReadFromDisk4000K\":0,\"ObjectsAsyncLruToDisk\":0,\"DependencyIdsOffloadedToDisk\":0,\"TimeoutInvalidationsFromMemory\":0,\"RemoteObjectUpdates\":0,\"ObjectsWriteToDisk4K\":0,\"DependencyIdsOnDisk\":0,\"RemoteObjectFetchSize\":0,\"ObjectsDeleteFromDisk4K\":0,\"OverflowEntriesFromMemory\":0,\"CacheRemoves\":0,\"ExplicitInvalidationsLocal\":0,\"TemplatesOnDisk\":0,\"DiskCacheSizeInMB\":0.0,\"TemplatesOffloadedToDisk\":0,\"ObjectsDeleteFromDiskSize\":0,\"CacheName\":\"baseCache\",\"DependencyIdsBufferedForDisk\":0,\"Monitor\":\"Dynacache\",\"CacheMisses\":0,\"RemoteInvalidationNotifications\":0,\"RemoteObjectMisses\":0,\"ObjectsOnDisk\":0,\"CacheHits\":0,\"ObjectsReadFromDiskSize\":0,\"ObjectsWriteToDisk\":0,\"TimeoutInvalidationsFromDisk\":0,\"ObjectsDeleteFromDisk400K\":0,\"TemplatesBufferedForDisk\":0,\"MemoryCacheSizeInMB\":-1.0,\"MemoryCacheEntries\":1,\"ObjectsWriteToDiskSize\":0,\"ObjectsReadFromDisk4K\":0,\"RemoteObjectHits\":0,\"ExplicitInvalidationsFromMemory\":0,\"RemoteObjectUpdateSize\":0,\"ObjectsReadFromDisk40K\":0,\"ObjectsDeleteFromDisk4000K\":0,\"PendingRemovalFromDisk\":0,\"ObjectsDeleteFromDisk\":0,\"CacheLruRemoves\":0}","ibm_threadId":"0000005d","ibm_datetime":"2019-11-20T15:50:42.590-0500","module":"monitor","loglevel":"INFO","ibm_methodName":"baseCache","ibm_className":"dynacache_stats","ibm_sequence":"1574283042590_000000000021E","ext_thread":"pool-3-thread-1"} 
 
The statistics are  now available for manual review in the logs 

 

As a next step, and when the logs are redirected to ElasticSearch/Kibana,  we define the following ingress pipeline: 
 

{ 

    "processors": [{ 

        "json": { 

            "if": "ctx.ibm_className == 'dynacache_stats'", 

            "field": "message", 

            "add_to_root": true 

        } 

    }, 

    { 

        "remove": { 

            "if": "ctx.ibm_className == 'dynacache_stats'", 

            "field": "message" 

        } 

    }] 

} 

 
This is pipeline, the encoded json inside the 'message' attribute is exported out to the root element of the JSON object, making them available for querying 
 

With the formatted JSON object, we can now easily create tables and charts, that are continuously populated/updated. For example,  
"Cache Sizes by POD". This allow us in a very dynamic fashion to keep track of the state of all the caches in all the servers  
 

 
 

 

 
