# Redis Compatibility 

Redis Enterprise Software Compatibility with Open Source Redis  

https://docs.redislabs.com/latest/rs/concepts/compatibility/ 

 

 

AWS Restricted Redis Commands 

https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/RestrictedCommands.html 

 

 

Memorystore for Redis Product constraints 

https://cloud.google.com/memorystore/docs/redis/product-constraints 

 

Azure Commands 

https://azure.microsoft.com/en-us/updates/redis-60-is-now-in-preview-for-azure-cache-for-redis/ 

 

 

Environments 

 

AWS 

redis-cli -h redis-15493.c61.us-east-1-3.ec2.cloud.redislabs.com -p 15493 -a 53jiJlOv0EbhcSasrSbWkbxaOkiWKtVW 

 

Google Cloud 

redis-cli -h 10.230.61.11 -p 6379 

 

=========================== 

 

Google cloud includes maxmemory details with the INFO command but Redis Lab cloud doesn't 

 

Google 

 

$ redis-cli -h 10.230.61.11 -p 6379 info | grep maxmemory 

maxmemory:1073741824 

maxmemory_human:1.00G 

maxmemory_policy:volatile-lru 

 

Redislab 

 

$ redis-cli -h redis-15493.c61.us-east-1-3.ec2.cloud.redislabs.com -p 15493 -a 53jiJlOv0EbhcSasrSbWkbxaOkiWKtVW info  | grep memory 

Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe. 

used_memory:1934704 

used_memory_human:1.84M 

used_memory_rss:1934704 

used_memory_peak:2812224 

used_memory_peak_human:2.68M 

used_memory_lua:37888 

 

 

Azure 
 

# Memory 

used_memory:542290912 

used_memory_human:517.16M 

used_memory_rss:542290912 

used_memory_peak:544131152 

used_memory_peak_human:518.92M 

used_memory_lua:75776 

mem_fragmentation_ratio:1 

mem_allocator:jemalloc-5.1.0 
