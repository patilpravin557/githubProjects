db restore 

  

[db2inst1@perf-cluster-2-db2 918_200k]$ db2 force application all 

DB20000I  The FORCE APPLICATION command completed successfully. 

DB21024I  This command is asynchronous and may not be effective immediately. 

  

[db2inst1@perf-cluster-2-db2 918_200k]$ db2 restore db mall 

SQL2523W  Warning!  Restoring to an existing database that is different from 

the database on the backup image, but have matching names. The target database 

will be overwritten by the backup version.  The Roll-forward recovery logs 

associated with the target database will be deleted. 

Do you want to continue ? (y/n) y 

DB20000I  The RESTORE DATABASE command completed successfully. 

[db2inst1@perf-cluster-2-db2 918_200k]$ db2 connect to mall 

  

   Database Connection Information 

  

Database server        = DB2/LINUXX8664 11.5.0.0 

SQL authorization ID   = DB2INST1 

Local database alias   = MALL 

  

[db2inst1@perf-cluster-2-db2 918_200k]$ db2 "SELECT COUNT(*) FROM wcs.CATENTRY" 

  

1 

----------- 

     214232 

  

  1 record(s) selected. 

*************************************************************************************** 

 

 

To use the new index follow below steps 

 

Follow below process for auth.reindex and do the push to live using cloud shell automatically build the index as well as connector 

 

oot@cs-548929158130-default-default-fm8z7:/etc# curl -k -u spiuser:passw0rd -X POST "https://tsapp.demoqalive.pravin.perf-gcp-cluster.com/wcs/resources/admin/index/dataImport/build?connectorId=push-to-live&storeId=11" 

{"jobStatusId":"1001"}root@cs-548929158130-default-default-fm8z7:/etc# 

root@cs-548929158130-default-default-fm8z7:/etc# 

root@cs-548929158130-default-default-fm8z7:/etc# 

root@cs-548929158130-default-default-fm8z7:/etc# curl -k -u spiuser:passw0rd -X GET "https://tsapp.demoqalive.pravin.perf-gcp-cluster.com/wcs/resources/admin/index/dataImport/status?jobStatusId=1001" 

{"status":{"finishTime":"2021-10-04 17:28:19.978193","lastUpdate":"2021-10-04 17:28:19.978193","progress":"100%","jobStatusId":"1001","startTime":"2021-10-04 17:27:33.355702","runId":"i-399908c0-864d-437f-b816-1dac8c228eef","message":"Ingest job finished successfully for storeId: 11. ","job 
