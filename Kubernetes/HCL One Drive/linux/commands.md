
tar -cvf  heapdump.20201029.062500.240.0010.tar heapdump.20201029.062500.240.0010.phd 

  

 gzip -v heapdump.20201029.062500.240.0010.tar 

bzip2 -v heapdump.20201029.062500.240.0010.tar.gz 



find / -name health* -print

[root@demoqaauthts-app-889867cfb-tsg4d server1]#  

grep " W " TextLog_20.10.01_00.00.01_server1.log 

 
[10/1/20 0:00:26:163 GMT] 00007bcb HCLCache      W com.hcl.commerce.cache.remote.HCLCache getRedisson() Reconfiguring maximum TTL to 300 
[10/1/20 0:00:26:166 GMT] 00007bcb HCLCache      W com.hcl.commerce.cache.remote.HCLCache getRedisson() Reconfiguring maximum TTL to 300 
[10/1/20 0:00:26:311 GMT] 00007bcb HCLCache      W com.hcl.commerce.cache.remote.HCLCache getRedisson() Reconfiguring maximum TTL to 300 
[10/1/20 0:00:28:920 GMT] 00007bcb HCLCache      W com.hcl.commerce.cache.remote.HCLCache getCacheEntry( String cacheId, boolean bFetchMedaData ) services/cache/WCSystemDistributedMapCache Cache entry in local cache is expired. Not using. cacheid: com.ibm.commerce.dynacache.commands.AbstractDistributedMapCache$Cache:com.ibm.commerce.price.commands.PriceListRegistry:[CachedUID]: currentTimeMs: 1,601,510,428,920 expiry time: 1,601,457,787,153 - delta: 52,641,767 
[10/1/20  

 

 

grep " W " *.log | grep LocalHclCache 

 

grep " W " *.log | grep -i LocalHclCache 

 
