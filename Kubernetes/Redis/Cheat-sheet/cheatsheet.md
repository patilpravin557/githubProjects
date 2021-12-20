 

Redis Docker Container 

 

docker run --name redis  -e ALLOW_EMPTY_PASSWORD=yes -p 6379:6379 bitnami/redis:latest 

docker exec -u 0 -it redis  bash 
 
With password: 
docker run --name redis -e REDIS_PASSWORD=wcs1 -p 6379:6379 bitnami/redis:latest 

 

In bash:  

redis-cli 

 

Redis Commands 

https://redis.io/commands 

 

KEYS key* 

Query keys. Use * wildcard 

 

HGETALL <id> 

See contents of a cache entry 

 

SMEMBERS <dep> 

List all cache ids in a dependency 

 

TTL <key> 

Time to live for a key in seconds 

 

FLUSHALL 

Delete all keys 

 

 

PUBSUB CHANNELS 

Lists all active channels (topics) 

 

SUBSCRIBE 

subscribe "{cache-baseCache}-invalidation" 

 

Subscribes to a topic. Can be used to see invalidations are they are flowing to the different caches 

 

 

Troubleshooting 

 

MONITOR 

shows all commands as they are executed on the server. Very useful for debugging 

 

redis-cli --intrinsic-latency 100 

 

LATENCY DOCTOR 

 

SLOWLOG 

 

https://redis.io/topics/latency 

https://redis.io/topics/persistence 

 

 

 

 
