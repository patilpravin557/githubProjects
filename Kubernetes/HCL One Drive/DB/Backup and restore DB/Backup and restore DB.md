kubectl delete pod <pod_name> -n <namespace> --grace-period 0 

 scp-r tmp/MALL.0.db2instp1.DBPART000.20200730022625.001 db2inst1@10.190.66.215:/home/db2inst1/ 

  

chmod -R o+rwx MALL.0.db2inst1.DBPART000.20200730022625.001 

 

**************update db2****************** 

[10:15 PM] Raimee Stevens 

[db2inst1@COMP-2228-1 ~]$ history | grep db2updv 
    1  /opt/ibm/db2/V11.1/bin/db2updv111 -a 
    2  /opt/ibm/db2/V11.1/bin/db2updv111 -d mall -u db2inst1 -p diet4coke -a 
   75  /opt/ibm/db2/V11.1/bin/db2updv111 -d mall -u db2inst1 -p diet4coke -a 
  772  find / -name db2updv* -print 
  773  history | grep db2updv111 
  774   /opt/ibm/db2/V11.1/bin/db2updv111 -d mall -u db2inst1 -p diet4coke -a 
  998  grep history for db2updv 
1000  history | grep db2updv 
[db2inst1@COMP-2228-1 ~]$ 
 
 
  

  

[10:16 PM] Raimee Stevens 

db2updv111 -d mall -u db2inst1 -p diet4coke -a 
/opt/ibm/db2/V11.1/bin/db2updv111 -d auth -u db2inst1 -p diet4coke -a 
 

 

 

****************Backup********************************* 

 db2 force applications all 

And immediately run the backup command  

db2 backup database mall to /home/db2inst1/db2_backup/ 

 

 

 [db2inst1@demoqaauthdb-65b59cddd6-lqqvt ~]$ db2 force applications all 

DB20000I  The FORCE APPLICATION command completed successfully. 

DB21024I  This command is asynchronous and may not be effective immediately. 

  

[db2inst1@demoqaauthdb-65b59cddd6-lqqvt ~]$ db2 list applications 

SQL1611W  No data was returned by Database System Monitor. 

[db2inst1@demoqaauthdb-65b59cddd6-lqqvt ~]$ db2 terminate 

DB20000I  The TERMINATE command completed successfully. 

[db2inst1@demoqaauthdb-65b59cddd6-lqqvt ~]$ db2 deactivate database mall 

DB20000I  The DEACTIVATE DATABASE command completed successfully. 

[db2inst1@demoqaauthdb-65b59cddd6-lqqvt ~]$ db2 backup database mall to /home/db2inst1/db2_backup/ 

  

Backup successful. The timestamp for this backup image is : 20200710094937 

  

[db2inst1@demoqaauthdb-65b59cddd6-lqqvt db2_backup]$ ls 

MALL.0.db2inst1.DBPART000.20200710094937.001  db2inst1 

  

********************************************************************* 

  

*********************************RESTORE*********************************** 

[db2inst1@demoqaauthdb-65b59cddd6-lqqvt ~]$ db2 restore db MALL from /home/db2inst1/db2_backup/ TAKEN AT 20200710094937 TO AUTH INTO AUTH 

SQL2529W  Warning!  Restoring to an existing database that is different from 

the backup image database, and the alias name "AUTH" of the existing database 

does not match the alias name "MALL" of the backup image, and the database 

name "AUTH" of the existing database does not match the database name "MALL" 

of the backup image. The target database will be overwritten by the backup 

version. The Roll-forward recovery logs associated with the target database 

will be deleted. 

Do you want to continue ? (y/n) y 

DB20000I  The RESTORE DATABASE command completed successfully. 

  

[db2inst1@demoqaauthdb-65b59cddd6-lqqvt ~]$ db2 connect to auth 

SQL1117N  A connection to or activation of database "AUTH" cannot be made 

because of ROLL-FORWARD PENDING.  SQLSTATE=57019 

  

[db2inst1@demoqaauthdb-65b59cddd6-lqqvt ~]$ db2 rollforward db auth to end of logs and stop 

  

                                 Rollforward Status 

  

Input database alias                   = auth 

Number of members have returned status = 1 

  

Member ID                              = 0 

Rollforward status                     = not pending 

Next log file to be read               = 

Log files processed                    =  - 

Last committed transaction             = 2020-07-10-09.49.51.000000 UTC 

  

DB20000I  The ROLLFORWARD command completed successfully. 

[db2inst1@demoqaauthdb-65b59cddd6-lqqvt ~]$ db2 connect to auth 

  

   Database Connection Information 

  

Database server        = DB2/LINUXX8664 11.5.0.0 

SQL authorization ID   = DB2INST1 

Local database alias   = AUTH 

  

[db2inst1@demoqaauthdb-65b59cddd6-lqqvt ~]$ db2 "CALL GET_DBSIZE_INFO (?, ?, ?, -1)" 

  

  Value of output parameters 

  -------------------------- 

  Parameter Name  : SNAPSHOTTIMESTAMP 

  Parameter Value : 2020-07-10-10.12.06.284018 

  

  Parameter Name  : DATABASESIZE 

  Parameter Value : 1595764736 

  

  Parameter Name  : DATABASECAPACITY 

  Parameter Value : 18738954240 

  

  Return Status = 0 

[db2inst1@demoqaauthdb-65b59cddd6-lqqvt ~]$ db2 connect reset 

DB20000I  The SQL command completed successfully. 

[db2inst1@demoqaauthdb-65b59cddd6-lqqvt ~]$ db2 connect to mall 

  

   Database Connection Information 

  

Database server        = DB2/LINUXX8664 11.5.0.0 

SQL authorization ID   = DB2INST1 

Local database alias   = MALL 

  

[db2inst1@demoqaauthdb-65b59cddd6-lqqvt ~]$ db2 "CALL GET_DBSIZE_INFO (?, ?, ?, -1)" 

  

  Value of output parameters 

  -------------------------- 

  Parameter Name  : SNAPSHOTTIMESTAMP 

  Parameter Value : 2020-07-10-10.12.48.888432 

  

  Parameter Name  : DATABASESIZE 

  Parameter Value : 1595764736 

  

  Parameter Name  : DATABASECAPACITY 

  Parameter Value : 18771570688 

  

  Return Status = 0 

[db2inst1@demoqaauthdb-65b59cddd6-lqqvt ~]$ 

 

 

Restoring pre-loaded MALL DB from Noureddine's Env. to new MALL and AUTH DB's for our Cluster 

 

working on setting up the env. Have got a v9.1 database with large catalog deployed now. Sharing 

commands, DB names and location of images fyi. 

  

MALL will be the name of the LIVE instance DB, and AUTH will be the name of the AUTH instance DB 

  

I copied Noureddine's preloaded MALL DB from his env. to the DB server we are using for our k8s cluster. And then I restored 

it to two DB's used for our k8s env. LIVE and AUTH deployments. 

  

You can find it backup image here: 

  

[db2inst1@COMP-2228-1 v91]$ pwd 

/db/db_backups/bigcat/v91  

  

It's about 15GB: 

  

[db2inst1@COMP-2228-1 v91]$ ls -l  

total 14863948  

-rw-------. 1 db2inst1 db2iadm1 15220682752 Jul  8 14:02 MALL.0.db2inst1.DBPART000.20200623153451.001  

  

This is the command used to restore to a different name (the backup name is MALL and target is AUTH): 

  

[db2inst1@COMP-2228-1 v91]$ db2 restore db MALL from /db/db_backups/bigcat/v91 TAKEN AT 20200623153451 TO AUTH INTO AUTH 

SQL2529W  Warning!  Restoring to an existing database that is different from  

the backup image database, and the alias name "AUTH" of the existing database  

does not match the alias name "MALL" of the backup image, and the database  

name "AUTH" of the existing database does not match the database name "MALL"  

of the backup image. The target database will be overwritten by the backup  

version. The Roll-forward recovery logs associated with the target database  

will be deleted.  

Do you want to continue ? (y/n) y  

DB20000I  The RESTORE DATABASE command completed successfully.  

  

-> Inspect DB size_info for AUTH DB: 

  

[db2inst1@COMP-2228-1 v91]$ db2 connect to auth  

  

   Database Connection Information  

  

 Database server        = DB2/LINUXX8664 11.1.4.5  

 SQL authorization ID   = DB2INST1  

 Local database alias   = AUTH  

  

[db2inst1@COMP-2228-1 v91]$ db2 "CALL GET_DBSIZE_INFO (?, ?, ?, -1)"  

  

  Value of output parameters  

  --------------------------  

  Parameter Name  : SNAPSHOTTIMESTAMP  

  Parameter Value : 2020-07-08-15.18.30.178374 

  

  

  Parameter Name  : DATABASESIZE  

  Parameter Value : 15183900672  

  

  Parameter Name  : DATABASECAPACITY  

  Parameter Value : 102307774464  

  

  Return Status = 0  

[db2inst1@COMP-2228-1 v91]$ db2 connect reset  

DB20000I  The SQL command completed successfully.  

  

-> Compare to MALL 

  

[db2inst1@COMP-2228-1 v91]$ db2 connect to mall  

  

   Database Connection Information  

  

 Database server        = DB2/LINUXX8664 11.1.4.5  

 SQL authorization ID   = DB2INST1  

 Local database alias   = MALL  

  

[db2inst1@COMP-2228-1 v91]$ db2 "CALL GET_DBSIZE_INFO (?, ?, ?, -1)"  

  

  Value of output parameters  

  --------------------------  

  Parameter Name  : SNAPSHOTTIMESTAMP  

  Parameter Value : 2020-07-08-15.18.47.026987  

  

  Parameter Name  : DATABASESIZE  

  Parameter Value : 15183900672  

  

  Parameter Name  : DATABASECAPACITY  

  Parameter Value : 102307774464  

  

  Return Status = 0  

  

So now the DB's are in sync. and I can begin to redeploy the LIVE and AUTH Commerce instances. Will send you 

an update when that is done. 

 

 

*********************** 

 

[db2inst1@COMP-2228-1 9.1.1.backup]$ db2 restore db mall from /db/db_backups/9.1.1.backup/mall/ taken at 20200730040627 

SQL2539W  The specified name of the backup image to restore is the same as the 

name of the target database.  Restoring to an existing database that is the 

same as the backup image database will cause the current database to be 

overwritten by the backup version. 

Do you want to continue ? (y/n) y 

DB20000I  The RESTORE DATABASE command completed successfully. 
