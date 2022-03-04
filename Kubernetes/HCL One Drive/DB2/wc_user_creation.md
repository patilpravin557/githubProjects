[db2inst1@perf-cluster-2-db2 ~]$ db2 connect to mall user db2inst1 using diet4coke 

Database Connection Information 

Database server = DB2/LINUXX8664 11.5.0.0 
SQL authorization ID = DB2INST1 
Local database alias = MALL 

[db2inst1@perf-cluster-2-db2 ~]$ db2 connect to mall user wcs using wcs1 
SQL30082N Security processing failed with reason "24" ("USERNAME AND/OR 
PASSWORD INVALID"). SQLSTATE=08001 
[db2inst1@perf-cluster-2-db2 ~]$ 

 

 

[root@BLMYCLDTL18171 home]# userdel -r wcs 

[root@BLMYCLDTL18171 home]# adduser wcs 

[root@BLMYCLDTL18171 home]# passwd wcs 

Changing password for user wcs. 

New password: 

BAD PASSWORD: The password is shorter than 7 characters 

Retype new password: 

passwd: all authentication tokens updated successfully. 

 

 

[db2inst1@BLMYCLDTL18171 ~]$ db2 connect to mall user db2inst1 using diet4coke 

  

   Database Connection Information 

  

Database server        = DB2/LINUXX8664 11.5.0.0 

SQL authorization ID   = DB2INST1 

Local database alias   = MALL 

  

[db2inst1@BLMYCLDTL18171 ~]$ db2 connect to mall user wcs using wcs1 

  

   Database Connection Information 

  

Database server        = DB2/LINUXX8664 11.5.0.0 

SQL authorization ID   = WCS 

Local database alias   = MALL 

  

[db2inst1@BLMYCLDTL18171 ~]$ 
