kubectl cp dump.rdb redisc-redis-cluster-0:/bitnami/redis/data/dump.rdb -n redisc -c redisc-redis-cluster 

 

docker start redis 

docker stop redis 

docker exec -it redis redis-cli 

docker exec redis redis-cli dbsize 

keys *size_m_1*WCT+?* 

scard  "{cache-demoqalive-services/loadtest/cache/size_xs_1}-dep-WCT+?" 

(integer) 0 

smembers "{cache-demoqalive-services/loadtest/cache/size_xs_1}-dep-WCT+SIZE_XS_1+010-005" 

 

 

127.0.0.1:6379> scard "{cache-demoqalive-baseCache}-dep-WCT+ESINDEX" 

(integer) 174208 

127.0.0.1:6379> scard "{cache-demoqalive-baseCache}-dep-&ALL&" 

(integer) 175199 

127.0.0.1:6379> scard "{cache-demoqalive-baseCache}-dep-WCT+FULL_ESINDEX" 

(integer) 177150 

127.0.0.1:6379> 

  

"baseCache": 250859, 

  

[root@com-kube-master ~]# time curl -k -X DELETE "https://cache.demoqalive.pravin.svt.hcl.com/cm/cache/invalidate?cache=baseCache&id=WCT%2BESINDEX" -H "accept: */*" 

  

real    0m58.741s 

user    0m0.060s 

sys     0m0.099s 

[root@com-kube-master ~]# 

  

"baseCache": 250335, 

  

[root@com-kube-master ~]# time curl -k -X DELETE "https://cache.demoqalive.pravin.svt.hcl.com/cm/cache/clear?cache=baseCache&allowUnregisteredCache=false" -H "accept: */*" 

  

real    1m5.571s 

user    0m0.047s 

sys     0m0.086s 

[root@com-kube-master ~]# 

 

parallel -u ::: './curl_shell_1.sh 1' './curl_shell_2.sh 2' './curl_shell_3.sh 3' './curl_shell_4.sh 4' './curl_shell_5.sh 5' './curl_shell_6.sh 6' './curl_shell_7.sh 7' './curl_shell_8.sh 8' './curl_shell_9.sh 9' './curl_shell_10.sh 10' 

  

parallel -u ::: './curl_shell_11.sh 1' './curl_shell_12.sh 2' './curl_shell_13.sh 3' './curl_shell_14.sh 4' './curl_shell_15.sh 5' './curl_shell_16.sh 6' './curl_shell_17.sh 7' './curl_shell_18.sh 8' './curl_shell_19.sh 9' './curl_shell_20.sh 10' 

 

 

 

 

Dependency id is tag for multiple cache ids 

 

This is the cache Entry 

"{cache-demoqalive-services/cache/WCSystemDistributedMapCache}-data-com.ibm.commerce.dynacache.commands.AbstractDistributedMapCache$Cache:com.ibm.commerce.common.objects.CurrencyFormatAccessBean:[findByPrimaryKey, -1, RON, 11]:" 

 

keys *WCSystemDistributedMapCache* (data + dep) 

   1) "{cache-demoqalive-services/cache/WCSystemDistributedMapCache}-dep-WCT+CURFMTDESC+LANGUAGE_ID+NUMBRUSG_ID+SETCCURR+STOREENT_ID:%:-3:?:%:ESP:?" 

   2) "{cache-demoqalive-services/cache/WCSystemDistributedMapCache}-dep-WCT+CURFMTDESC+LANGUAGE_ID+NUMBRUSG_ID+SETCCURR+STOREENT_ID:%:-3:?:%:GBP:%:-1" 

     18) "{cache-demoqalive-services/cache/WCSystemDistributedMapCache}-data-com.ibm.commerce.dynacache.commands.AbstractDistributedMapCache$Cache:com.ibm.commerce.common.objects.CurrencyFormatAccessBean:[findByPrimaryKey, -3, USD, 11]:" 

 

Cache entries (All data) 

127.0.0.1:6379> keys *WCSystemDistributedMapCache*-data* 

  1) "{cache-demoqalive-services/cache/WCSystemDistributedMapCache}-data-com.ibm.commerce.dynacache.commands.AbstractDistributedMapCache$Cache:com.ibm.commerce.common.objects.CurrencyFormatAccessBean:[findByPrimaryKey, -3, USD, 11]:" 

  2) "{cache-demoqalive-services/cache/WCSystemDistributedMapCache}-data-com.ibm.commerce.dynacache.commands.AbstractDistributedMapCache$Cache:com.ibm.commerce.common.objects.CurrencyFormatAccessBean:[findByPrimaryKey, -1, USD, 0]:" 

  3) "{cache-demoqalive-services/cache/WCSystemDistributedMapCache}-data-com.ibm.commerce.dynacache.commands.AbstractDistributedMapCache$Cache:com.ibm.commerce.user.objects.MemberGroupAccessBean:[findByPrimaryKey, -161]:" 

  4) "{cache-demoqalive-services/cache/WCSystemDistributedMapCache}-data-com.ibm.commerce.dynacache.commands.AbstractDistributedMapCache$Cache:com.ibm.commerce.user.objects.OrganizationAccessBean:[findByPrimaryKey, -2001]:" 

  5) "{cache-demoqalive-services/cache/WCSystemDistributedMapCache}-data-com.ibm.commerce.dynacache.commands.AbstractDistributedMapCache$Cache:com.ibm.commerce.foundation.internal.server.services.search.util.StoreHelper.storeconf:[findStoreconfByStoreIdAndName, 11, null, wc.externalContent.authUriAssetPathPrefix]:" 

 

(data and its dependancy) pick one cache entry from above 

127.0.0.1:6379> hgetall "{cache-demoqalive-services/cache/WCSystemDistributedMapCache}-data-com.ibm.commerce.dynacache.commands.AbstractDistributedMapCache$Cache:com.ibm.commerce.common.objects.CurrencyFormatAccessBean:[findByPrimaryKey, -1, RON, 11]:" 

1) "inactivity" 

2) "86400" 

3) "dependencies" 

4) "WCT+CURFORMAT+NUMBRUSG_ID+SETCCURR+STOREENT_ID:?:%:RON:%:11;;;WCT+CURFORMAT+NUMBRUSG_ID+SETCCURR+STOREENT_ID:?:%:RON:?;;;WCT+?;;;WCT+CURFORMAT+NUMBRUSG_ID+SETCCURR+STOREENT_ID:%:-1:?:?;;;WCT+CURFORMAT+NUMBRUSG_ID+SETCCURR+STOREENT_ID:%:-1:%:RON:%:11;;;WCT+CURFORMAT+?;;;WCT+CURFORMAT+NUMBRUSG_ID+SETCCURR+STOREENT_ID:%:-1:%:RON:?;;;WCT+CURFORMAT+NUMBRUSG_ID+SETCCURR+STOREENT_ID:?:?:?;;;WCT+CURFORMAT+NUMBRUSG_ID+SETCCURR+STOREENT_ID:%:-1:?:%:11;;;WCT+CURFORMAT+NUMBRUSG_ID+SETCCURR+STOREENT_ID:?:?:%:11;;;" 

5) "value" 

6) "\x04\x04\t>/com.ibm.commerce.datatype.CacheableFinderResultl0\xeb;f\"r\x1d\x00\x00\x00\x00\t>.com.ibm.commerce.datatype.AbstractFinderResultU\xb2\xfe]\xd1\xa0\x14\x19\x00\x00\x00\x11>\x10iCachedException\x16\x00>\x0ciContextInfo\x16\x00>\x13iDefaultContextInfo\x16\x00>\x19iDefaultWrappedFinderArgs\x16\x00>\x0biExpiryTime\x16\x00>\niFootprint$\x00>\x1fiMaxAdditionalTimeToLiveSeconds#\x00>\x19iMaxInactivityTimeSeconds#\x00>\x15iMaxTimeToLiveSeconds#\x00>\x16iNoResultExceptionType\"\x00>\x12iWrappedFinderArgs\x16\x00>\x14ibCacheResultEnabled \x00>\x0eibReduceMemory \x00>\x11icollCachedResult\x16\x00>\x12icollDependencyIds\x16\x00>\x15istrDefaultFinderName\x16\x00>\x0eistrFinderName\x16\x00\x16\x01\x01RZ\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xa8\xc0\x00\x01Q\x80\x00\x02\xa3\x00\x00\x02S\x04Z>\x10findByPrimaryKeyK\xff\xff\xff\xff>\x03RONK\x00\x00\x00\x0b\x01\x00\x01S\nZ>;WCT+CURFORMAT+NUMBRUSG_ID+SETCCURR+STOREENT_ID:?:%:RON:%:11>8WCT+CURFORMAT+NUMBRUSG_ID+SETCCURR+STOREENT_ID:?:%:RON:?>\x05WCT+?>7WCT+CURFORMAT+NUMBRUSG_ID+SETCCURR+STOREENT_ID:%:-1:?:?>>WCT+CURFORMAT+NUMBRUSG_ID+SETCCURR+STOREENT_ID:%:-1:%:RON:%:11>\x0fWCT+CURFORMAT+?>;WCT+CURFORMAT+NUMBRUSG_ID+SETCCURR+STOREENT_ID:%:-1:%:RON:?>4WCT+CURFORMAT+NUMBRUSG_ID+SETCCURR+STOREENT_ID:?:?:?>:WCT+CURFORMAT+NUMBRUSG_ID+SETCCURR+STOREENT_ID:%:-1:?:%:11>7WCT+CURFORMAT+NUMBRUSG_ID+SETCCURR+STOREENT_ID:?:?:%:11\x01>8com.ibm.commerce.common.objects.CurrencyFormatAccessBean" 

7) "expiry-at" 

8) "1611259162947" 

9) "created-at" 

10) "1611053695948" 

11) "created-by" 

12) "demoqalivets-app-6b56775cc4-9gvtc" 

 

keys *WCSystemDistributedMapCache*WCT+?* 

   1) "{cache-demoqalive-services/cache/WCSystemDistributedMapCache}-dep-WCT+CURFMTDESC+LANGUAGE_ID+NUMBRUSG_ID+SETCCURR+STOREENT_ID:%:-3:?:%:ESP:?" 

   2) "{cache-demoqalive-services/cache/WCSystemDistributedMapCache}-dep-WCT+CURFMTDESC+LANGUAGE_ID+NUMBRUSG_ID+SETCCURR+STOREENT_ID:%:-3:?:%:GBP:%:-1" 

   3) "{cache-demoqalive-services/cache/WCSystemDistributedMapCache}-dep-WCT+MBRGRP+MBRGRP_ID:?" 

   4) "{cache-demoqalive-services/cache/WCSystemDistributedMapCache}-dep-WCT+CURFMTDESC+LANGUAGE_ID+NUMBRUSG_ID+SETCCURR+STOREENT_ID:%:-23:%:-1:%:ZAR:%:-1" 

   5) "{cache-demoqalive-services/cache/WCSystemDistributedMapCache}-dep-WCT+CURFMTDESC+LANGUAGE_ID+NUMBRUSG_ID+SETCCURR+STOREENT_ID:%:-20:%:-1:%:RON:%:-1" 

   6) "{cache-demoqalive-services/cache/WCSystemDistributedMapCache}-dep-WCT+CURFMTDESC+LANGUAGE_ID+NUMBRUSG_ID+SETCCURR+STOREENT_ID:%:-20:?:%:ESP:?" 

   7) "{cache-demoqalive-services/cache/WCSystemDistributedMapCache}-dep-WCT+CURFMTDESC+LANGUAGE_ID+NUMBRUSG_ID+SETCCURR+STOREENT_ID:%:-23:?:%:ITL:%:-1" 

   8) "{cache-demoqalive-services/cache/WCSystemDistributedMapCache}-dep-WCT+CURFMTDESC+LANGUAGE_ID+NUM 

 

127.0.0.1:6379> smembers "{cache-demoqalive-services/cache/WCSystemDistributedMapCache}-dep-WCT+STOREENT+?" 

1) "com.ibm.commerce.dynacache.commands.AbstractDistributedMapCache$Cache:com.ibm.commerce.common.objects.StoreAccessBean:[findByPrimaryKey, 0]:" 

2) "com.ibm.commerce.dynacache.commands.AbstractDistributedMapCache$Cache:com.ibm.commerce.catalog.facade.server.cache.DefaultCatalogCache:[11]:" 

3) "com.ibm.commerce.dynacache.commands.AbstractDistributedMapCache$Cache:com.ibm.commerce.common.objects.StoreAccessBean:[findByPrimaryKey, 12001]:" 

4) "com.ibm.commerce.dynacache.commands.AbstractDistributedMapCache$Cache:com.ibm.commerce.common.objects.StoreAccessBean:[findByPrimaryKey, 11]:" 

5) "com.ibm.commerce.dynacache.commands.AbstractDistributedMapCache$Cache:com.ibm.commerce.common.objects.StoreAccessBean:[findByPrimaryKey, 10001]:" 

6) "com.ibm.commerce.dynacache.commands.AbstractDistributedMapCache$Cache:com.ibm.commerce.common.objects.StoreAccessBean:[findByPrimaryKey, 12501]:" 

7) "com.ibm.commerce.dynacache.commands.AbstractDistributedMapCache$Cache:com.ibm.commerce.common.objects.StoreAccessBean:[findByPrimaryKey, 10501]:" 

 

 

smembers "{cache-demoqalive-services/cache/WCSystemDistributedMapCache}-dep-WCT+?" 

  1) "com.ibm.commerce.dynacache.commands.AbstractDistributedMapCache$Cache:com.ibm.commerce.common.objects.StoreAccessBean:[findByPrimaryKey, 12001]:" 

  2) "com.ibm.commerce.dynacache.commands.AbstractDistributedMapCache$Cache:com.ibm.commerce.foundation.rest.util.StoreConfigurationHelper.currency:[CachedUID]:" 

  3) "com.ibm.commerce.dynacache.commands.AbstractDistributedMapCache$Cache:com.ibm.commerce.common.objects.CurrencyFormatAccessBean:[findByPrimaryKey, -1, ATS, 0]:" 

  4) "com.ibm.commerce.dynacache.commands.AbstractDistributedMapCache$Cache:com.ibm.commerce.common.objects.CurrencyFormatAccessBean:[findByPrimaryKey, -1, PLN, 0]:" 

  5) "com.ibm.commerce.dynacache.commands.AbstractDistributedMapCache$Cache:com.ibm.commerce.common.objects.LanguageDescriptionAccessBean:[findByPrimaryKey, -1, -21]:" 

  6) "com.ibm.commerce.dynacache.commands.AbstractDistributedMapCache$Cache:com.ibm.commerce.common.objects.CurrencyFormatAccessBean:[findByPrimaryKey, -1, NLG, 0]:" 

  7) "com.ibm.commerce.dynacache.commands.AbstractDistributedMapCache$Cache:com.ibm.commerce.common.objects.CurrencyFormatAccessBean:[findByPrimaryKey, -1, AUD, 0]:" 

  8) "com.ibm.commerce.dynacache.commands.AbstractDistributedMapCache$Cache:com.ibm.commerce.common.objects.CurrencyFormatAccessBean:[findByPrimaryKey, -3, USD, -1]:" 
