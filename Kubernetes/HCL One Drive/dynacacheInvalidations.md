https://jira02.hclpnp.com/browse/HC-7737 

I want to tell you about the DynaCacheInvalidation scheduler job  

This has traditionally been the way customers invalidate cache. Now we also have NiFi trigger invalidations, but that job is used a lot  

basically we have triggers that insert into the CACHEIVL table. The job runs every 4 minutes, pick up new changes and triggers them  

the job has some smarts to understand the data cache and do a few more things, like clearing registries or caches with special keywords  

so if you have a trigger on CATENTRY and update 10000 products, you will see that many entries in CACHEIVL 

The invalidate() code for the HCL Cache goes to Redis. it's fast for a single invalidation, but if you want to call 1000 times, then it will very slow. So we added some special code to batch in the JVM and give all the dependencies at once 

As this is the first customer reported issue, I'd like your help to prioritize testing 

basically client is inserting clearall in dataid, which is a special keyword to clear all the caches registered in the data cache plus base cache 

The batching logic has a bug. because it adds invalidations to an array and processes the caches one by one... but the problem is that if there is a clear and no invalidations the cache was missed 

I am not sure whether to give you a patch now, or I guess we can wait a couple of days until the branches are open again and I will just check in the code fix, as it is simple 

but in the meantime I'd like you to play around with the job to get familiar.... 

You can insert an id  

insert into wcs.cacheivl (dataid) values ('catalog:1000') 

and then open another window in Redis and do 

redis_cli monitor | grep PUBLISH | grep baseCache 

something like that 

  

The PUBLISH is just the message to the pods, not the invalidation, but as the invalidation is more difficult to grep for, the publish is a good way to tell if the invalidation fired or not 

  

[Wednesday 7:04 PM] Pravin Prakash Patil 

Okay 

 

Db2 "INSERT INTO wcs.cacheivl (template, dataid) WITH temp (id) AS ( SELECT 1 AS id FROM sysibm.sysdummy1 UNION ALL SELECT id + 1 AS id FROM temp WHERE id < 1000 ) SELECT null AS template, 'product:' || TO_CHAR( CURRENT TIMESTAMP, 'YYYYMMDDHH24MI') || id AS dataid FROM temp" 

 

 

if you do this: 

insert into wcs.cacheivl (dataid) values ('clearall') 

it will clear many caches. but it will fail now 

insert into cacheivl (template, dataid) values ('dmap:services/cache/SearchSystemDistributedMapCache','andres3') 
insert into cacheivl (template, dataid) values ('dmap:services/cache/SearchSystemDistributedMapCache','clearall') 
insert into cacheivl (template, dataid) values ('dmap:services/cache/SearchDistributedMapCache','clearall') 
insert into cacheivl (template, dataid) values ('dmap:services/cache/SearchFacetDistributedMapCache','clearall') 
insert into cacheivl (template, dataid) values ('dmap:services/cache/SearchCatHierarchyDistributedMapCache','clearall') 
insert into cacheivl (template, dataid) values ('dmap:services/cache/SearchQueryDistributedMapCache','clearall') 
insert into cacheivl (template, dataid) values ('dmap:baseCache','clearall') 

the job runs every 4 minutes...  

 

 

[Yesterday 7:56 PM] Robert Dunn 

Enable trace for com.ibm.commerce.dynacache.commands.DCInvalidationCmdImpl=all 

grep for "Rows processed from Cacheivl table:" 

That will show that the command looked for rows in the CACHEIVL table. 

You will also see that for invalidation messages that were sent from other JVMs and processed. 

(1 liked) 

 

run set-dynamic-trace-specification  

com.ibm.commerce.dynacache.commands.DCInvalidationCmdImpl=all 

 

[root@demoqalivets-app-b89f48964-kqkv9 /]# run set-dynamic-trace-specification com.ibm.commerce.dynacache.commands.DCInvalidationCmdImpl=all 

WASX7209I: Connected to process "server1" on node localhost using SOAP connector;  The type of process is: UnManagedProcess 

Trace Specification is set to com.ibm.commerce.dynacache.commands.DCInvalidationCmdImpl=all. 

  

[root@demoqalivets-app-b89f48964-kqkv9 /]# 

 

DELETE FROM wcs.cacheivl 
INSERT INTO wcs.cacheivl (template, dataid) VALUES ( 'dmap:services/cache/SearchSystemDistributedMapCache', 'dummy' ) 
INSERT INTO wcs.cacheivl (template, dataid) VALUES ( 'dmap:services/cache/SearchSystemDistributedMapCache', 'clearall' ) 

INSERT INTO wcs.cacheivl (dataid) VALUES ( 'clearall' ) 

 

INSERT INTO wcs.cacheivl (dataid) VALUES ( 'dmap:services/cache/baseCache, 'clearall' ) 

 

insert into cacheivl(template, dataid,InsertTime) values ('dmap:services/cache/ANFBreadCrumbDistributedMapCache', 'AllCachedANFBreadCrumbs',CURRENT TIMESTAMP ); 

 

db2 "INSERT INTO wcs.cacheivl (template, dataid) WITH temp (id) AS ( SELECT 1 AS id FROM sysibm.sysdummy1 UNION ALL SELECT id + 1 AS id FROM temp WHERE id < 5 ) SELECT 'dmap:services/cache/SearchSystemDistributedMapCache' AS template, 'product:' || TO_CHAR( CURRENT TIMESTAMP, 'YYYYMMDDHH24MI') || id AS dataid FROM temp" 

 

 

kc logs demoqalivets-app-6b56775cc4-sp6ht --since=1m | grep "Clearing cache" 

 

 

 

a) choose a dependency from redis 

b) enable tracing in ts-app 

c) enable redis-cli monitor 

e) insert into cache ivl 

f) wait for message in tsapp or redis monitor 

g) query redis ensure the dependedency id is empty 

 

1. I have selected the WCCatalogEntryDistributedMap cache 
2. Enabled the tacing in ts-app 
3. inseted the 11 values 
4. checked the messages from ts-app it looks like ts-app invalidated all 11 dataids 



[12/14/20 6:53:53:563 GMT] 0000004b ThreadPool    I   WSVR0652W: The size of thread pool "WebContainer" has reached 80 percent of its maximum. 

[12/14/2 

  

  

[root@com-kube-master ~]# kc get pods -n redis 

NAME             READY   STATUS    RESTARTS   AGE 

redis-master-0   2/2     Running   0          4d15h 

[root@com-kube-master ~]# kubectl scale statefulset redis-master -n redis --replicas=0 

statefulset.apps/redis-master scaled 

[root@com-kube-master ~]# kc get pods -n redis 

NAME             READY   STATUS        RESTARTS   AGE 

redis-master-0   0/2     Terminating   0          4d15h 

[root@com-kube-master ~]# date 

Mon Dec 14 02:17:12 EST 2020 

[root@com-kube-master ~]# 

  

  

  

[12/11 9:05 PM] Andres Voldman 

    monitor Redis 

  

redis-cli MONITOR | tee /tmp/monitor.log 

  

[12/11 9:06 PM] Andres Voldman 

     

I have no name!@redis-master-0:/tmp$ grep PUBLISH monitor.log | grep /SearchDistributedMapCache | wc -l 

5000 

  

'dmap:services/cache/SearchSystemDistributedMapCache' 

'dmap:services/cache/SearchDistributedMapCache' 

'dmap:services/cache/SearchFacetDistributedMapCache' 

'dmap:services/cache/SearchCatHierarchyDistributedMapCache' 

'dmap:services/cache/SearchQueryDistributedMapCache' 

 

db2 "SELECT COUNT(*) FROM wcs.CACHEIVL" 

 

db2 "DELETE FROM wcs.cacheivl" 

 

 

DELETE FROM wcs.cacheivl 

 
INSERT INTO wcs.cacheivl (template, dataid) WITH temp (id) AS ( SELECT 1 AS id FROM sysibm.sysdummy1 UNION ALL SELECT id + 1 AS id FROM temp WHERE id == clearall) SELECT null AS template, 'product:' || TO_CHAR( CURRENT TIMESTAMP, 'YYYYMMDDHH24MI') || id AS dataid FROM temp 

 
INSERT INTO wcs.cacheivl (template, dataid) WITH temp (id) AS ( SELECT 1 AS id FROM sysibm.sysdummy1 UNION ALL SELECT id + 1 AS id FROM temp WHERE id < 5000 ) SELECT 'dmap:services/cache/SearchSystemDistributedMapCache' AS template, 'product:' || TO_CHAR( CURRENT TIMESTAMP, 'YYYYMMDDHH24MI') || id AS dataid FROM temp 

 
INSERT INTO wcs.cacheivl (template, dataid) WITH temp (id) AS ( SELECT 1 AS id FROM sysibm.sysdummy1 UNION ALL SELECT id + 1 AS id FROM temp WHERE id < 5000 ) SELECT 'dmap:services/cache/SearchDistributedMapCache' AS template, 'product:' || TO_CHAR( CURRENT TIMESTAMP, 'YYYYMMDDHH24MI') || id AS dataid FROM temp 

 
INSERT INTO wcs.cacheivl (template, dataid) WITH temp (id) AS ( SELECT 1 AS id FROM sysibm.sysdummy1 UNION ALL SELECT id + 1 AS id FROM temp WHERE id < 5000 ) SELECT 'dmap:services/cache/SearchFacetDistributedMapCache' AS template, 'product:' || TO_CHAR( CURRENT TIMESTAMP, 'YYYYMMDDHH24MI') || id AS dataid FROM temp 

 
INSERT INTO wcs.cacheivl (template, dataid) WITH temp (id) AS ( SELECT 1 AS id FROM sysibm.sysdummy1 UNION ALL SELECT id + 1 AS id FROM temp WHERE id < 5000 ) SELECT 'dmap:services/cache/SearchCatHierarchyDistributedMapCache' AS template, 'product:' || TO_CHAR( CURRENT TIMESTAMP, 'YYYYMMDDHH24MI') || id AS dataid FROM temp 
 

 

 

 

db2 "INSERT INTO wcs.cacheivl (dataid) WITH temp (id) AS ( SELECT 1 AS id FROM sysibm.sysdummy1 UNION ALL SELECT id + 1 AS id FROM temp WHERE id < 5 ) SELECT 'base_Cache:' || TO_CHAR( CURRENT TIMESTAMP, 'YYYYMMDDHH24MI') || id AS dataid FROM temp" 

  

db2 "INSERT INTO wcs.cacheivl (template, dataid) WITH temp (id) AS ( SELECT 1 AS id FROM sysibm.sysdummy1 UNION ALL SELECT id + 1 AS id FROM temp WHERE id < 5 ) SELECT 'dmap:services/cache/SearchSystemDistributedMapCache' AS template, 'product:' || TO_CHAR( CURRENT TIMESTAMP, 'YYYYMMDDHH24MI') || id AS dataid FROM temp" 

db2 "INSERT INTO wcs.cacheivl (template, dataid) WITH temp (id) AS ( SELECT 1 AS id FROM sysibm.sysdummy1 UNION ALL SELECT id + 1 AS id FROM temp WHERE id < 15 ) SELECT 'dmap:services/cache/SearchDistributedMapCache' AS template, 'product:' || TO_CHAR( CURRENT TIMESTAMP, 'YYYYMMDDHH24MI') || id AS dataid FROM temp" 

db2 "INSERT INTO wcs.cacheivl (template, dataid) WITH temp (id) AS ( SELECT 1 AS id FROM sysibm.sysdummy1 UNION ALL SELECT id + 1 AS id FROM temp WHERE id < 3 ) SELECT 'dmap:services/cache/SearchFacetDistributedMapCache' AS template, 'product:' || TO_CHAR( CURRENT TIMESTAMP, 'YYYYMMDDHH24MI') || id AS dataid FROM temp" 

db2 "INSERT INTO wcs.cacheivl (template, dataid) WITH temp (id) AS ( SELECT 1 AS id FROM sysibm.sysdummy1 UNION ALL SELECT id + 1 AS id FROM temp WHERE id < 2 ) SELECT 'dmap:services/cache/SearchCatHierarchyDistributedMapCache' AS template, 'product:' || TO_CHAR( CURRENT TIMESTAMP, 'YYYYMMDDHH24MI') || id AS dataid FROM temp" 

db2 "INSERT INTO wcs.cacheivl (template, dataid) WITH temp (id) AS ( SELECT 1 AS id FROM sysibm.sysdummy1 UNION ALL SELECT id + 1 AS id FROM temp WHERE id < 4) SELECT 'dmap:services/cache/SearchQueryDistributedMapCache' AS template, 'product:' || TO_CHAR( CURRENT TIMESTAMP, 'YYYYMMDDHH24MI') || id AS dataid FROM temp" 

  

From ts-app 

[12/14/20 13:04:06:596 GMT] 0000058d DCInvalidatio 1 com.ibm.commerce.dynacache.commands.DCInvalidationCmdImpl performExecute Rows processed from Cacheivl table: 29000 

[12/14/20 13:04:06:608 GMT] 0000058d DCInvalidatio 1 com.ibm.commerce.dynacache.commands.DCInvalidationCmdImpl performExecute Rows processed from Cacheivl table: 0 

[root@com-kube-master ~]# 

  

From redis 

 

redis-cli MONITOR | tee  /tmp/monitor.log 

 

I have no name!@redis-master-0:/tmp$ grep PUBLISH monitor.log | grep /SearchSystemDistributedMapCache | wc -l 

5000 

I have no name!@redis-master-0:/tmp$ grep PUBLISH monitor.log | grep /SearchDistributedMapCache | wc -l 

15000 

I have no name!@redis-master-0:/tmp$ grep PUBLISH monitor.log | grep /SearchFacetDistributedMapCache | wc -l 

3000 

I have no name!@redis-master-0:/tmp$ grep PUBLISH monitor.log | grep /SearchCatHierarchyDistributedMapCache | wc -l 

2000 

I have no name!@redis-master-0:/tmp$ grep PUBLISH monitor.log | grep /SearchQueryDistributedMapCache | wc -l 

4000 

I have no name!@redis-master-0:/tmp$ 

  

  

Cache Clear 

 

delete from cacheivl 

 

insert into cacheivl ( dataid) values ('clearall') 

 insert into cacheivl ( dataid) values ('baseCache','clearall') 

 

db2 "INSERT INTO wcs.cacheivl (template, dataid) VALUES ( 'dmap:services/cache/SearchSystemDistributedMapCache', 'Test1' )" 

db2 "INSERT INTO wcs.cacheivl (template, dataid) VALUES ( 'dmap:services/cache/SearchSystemDistributedMapCache', 'clearall' )" 

  

  

db2 "INSERT INTO wcs.cacheivl (template, dataid) VALUES ( 'dmap:services/cache/SearchDistributedMapCache', 'Test2' )" 

db2 "INSERT INTO wcs.cacheivl (template, dataid) VALUES ( 'dmap:services/cache/SearchDistributedMapCache', 'clearall' )" 

  

  

db2 "INSERT INTO wcs.cacheivl (template, dataid) VALUES ( 'dmap:services/cache/SearchFacetDistributedMapCache', 'Test3' )" 

db2 "INSERT INTO wcs.cacheivl (template, dataid) VALUES ( 'dmap:services/cache/SearchFacetDistributedMapCache', 'clearall' )" 

  

  

db2 "INSERT INTO wcs.cacheivl (template, dataid) VALUES ( 'dmap:services/cache/SearchCatHierarchyDistributedMapCache', 'Test4' )" 

db2 "INSERT INTO wcs.cacheivl (template, dataid) VALUES ( 'dmap:services/cache/SearchCatHierarchyDistributedMapCache', 'clearall' )" 

  

  

db2 "INSERT INTO wcs.cacheivl (template, dataid) VALUES ( 'dmap:services/cache/SearchQueryDistributedMapCache', 'Test5' )" 

db2 "INSERT INTO wcs.cacheivl (template, dataid) VALUES ( 'dmap:services/cache/SearchQueryDistributedMapCache', 'clearall' )" 

 

 

grep PUBLISH tmp/monitor_auth.log 

In last check for the message   

1607952241.141266 [0 10.41.0.2:55710] "PUBLISH" "{cache-demoqalive-services/cache/SearchSystemDistributedMapCache}-invalidation" "[p:demoqalivets-app-b89f48964-kqkv9;t:1607952241167]> inv-cache-clear" 

1607952241.256100 [0 10.41.0.2:55742] "PUBLISH" "{cache-demoqalive-services/cache/SearchDistributedMapCache}-invalidation" "[p:demoqalivets-app-b89f48964-kqkv9;t:1607952241282]> inv-cache-clear" 

1607952241.263328 [0 10.41.0.2:55714] "PUBLISH" "{cache-demoqalive-services/cache/SearchFacetDistributedMapCache}-invalidation" "[p:demoqalivets-app-b89f48964-kqkv9;t:1607952241289]> inv-cache-clear" 

1607952241.393422 [0 10.41.0.2:55698] "PUBLISH" "{cache-demoqalive-services/cache/SearchCatHierarchyDistributedMapCache}-invalidation" "[p:demoqalivets-app-b89f48964-kqkv9;t:1607952241419]> inv-cache-clear" 

1607952241.396243 [0 10.41.0.2:55675] "PUBLISH" "{cache-demoqalive-services/cache/SearchQueryDistributedMapCache}-invalidation" "[p:demoqalivets-app-b89f48964-kqkv9;t:1607952241422]> inv-cache-clear" 

  

 ************Andres**********************8888888 

 

DELETE FROM wcs.cacheivl 

INSERT INTO wcs.cacheivl (dataid) WITH temp (id) AS ( SELECT 1 AS id FROM sysibm.sysdummy1 UNION ALL SELECT id + 1 AS id FROM temp WHERE id < 10000 ) SELECT 'base_Cache:' || TO_CHAR( CURRENT TIMESTAMP, 'YYYYMMDDHH24MI') || id AS dataid FROM temp 

INSERT INTO wcs.cacheivl (template, dataid) WITH temp (id) AS ( SELECT 1 AS id FROM sysibm.sysdummy1 UNION ALL SELECT id + 1 AS id FROM temp WHERE id < 5 ) SELECT 'dmap:services/cache/WCRESTTagDistributedMapCache' AS template, 'dmap11:dmap_product:' || TO_CHAR( CURRENT TIMESTAMP, 'YYYYMMDDHH24MI') || id AS dataid FROM temp 

INSERT INTO wcs.cacheivl (dataid) WITH temp (id) AS ( SELECT 1 AS id FROM sysibm.sysdummy1 UNION ALL SELECT id + 1 AS id FROM temp WHERE id < 5 ) SELECT 'base22_product:' || TO_CHAR( CURRENT TIMESTAMP, 'YYYYMMDDHH24MI') || id AS dataid FROM temp 

INSERT INTO wcs.cacheivl (template, dataid) WITH temp (id) AS ( SELECT 1 AS id FROM sysibm.sysdummy1 UNION ALL SELECT id + 1 AS id FROM temp WHERE id < 5 ) SELECT 'dmap:services/cache/WCRESTTagDistributedMapCache' AS template, 'dmap22:dmap_product:' || TO_CHAR( CURRENT TIMESTAMP, 'YYYYMMDDHH24MI') || id AS dataid FROM temp 

CREATE OR REPLACE VIEW wcs.cacheivl2 (template,dataid) AS SELECT CAST(template as VARCHAR(60)) template, CAST( dataid as VARCHAR(60)) dataid FROM wcs.cacheivl 

SELECT * FROM wcs.cacheivl2 

TEMPLATE                                                     DATAID 

------------------------------------------------------------ ------------------------------------------------------------ 

-                                                            base11_product:2021010814491 

-                                                            base11_product:2021010814492 

-                                                            base11_product:2021010814493 

-                                                            base11_product:2021010814494 

-                                                            base11_product:2021010814495 

dmap:services/cache/WCRESTTagDistributedMapCache             dmap11:dmap_product:2021010814491 

dmap:services/cache/WCRESTTagDistributedMapCache             dmap11:dmap_product:2021010814492 

dmap:services/cache/WCRESTTagDistributedMapCache             dmap11:dmap_product:2021010814493 

dmap:services/cache/WCRESTTagDistributedMapCache             dmap11:dmap_product:2021010814494 

dmap:services/cache/WCRESTTagDistributedMapCache             dmap11:dmap_product:2021010814495 

-                                                            base22_product:2021010814491 

-                                                            base22_product:2021010814492 

-                                                            base22_product:2021010814493 

-                                                            base22_product:2021010814494 

-                                                            base22_product:2021010814495 

dmap:services/cache/WCRESTTagDistributedMapCache             dmap22:dmap_product:2021010814491 

dmap:services/cache/WCRESTTagDistributedMapCache             dmap22:dmap_product:2021010814492 

dmap:services/cache/WCRESTTagDistributedMapCache             dmap22:dmap_product:2021010814493 

dmap:services/cache/WCRESTTagDistributedMapCache             dmap22:dmap_product:2021010814494 

dmap:services/cache/WCRESTTagDistributedMapCache             dmap22:dmap_product:2021010814495 

  20 record(s) selected. 
