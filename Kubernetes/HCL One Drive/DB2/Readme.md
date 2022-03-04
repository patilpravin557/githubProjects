[db2inst1@COMP-2228-1 ~]$ db2 " update wcs.userreg set PASSWORDEXPIRED = 0 where logonid like 'hcluser%' " 

DB20000I  The SQL command completed successfully. 

 

 

db2 " update wcs.plcypasswd set MAXLIFETIME = 99999 where logonid like 'hclu%' " 

update plcypasswd set MAXLIFETIME = 99999 

[db2inst1@COMP-4434-1 ~]$ db2 " update wcs.plcypasswd set MAXLIFETIME = 9999 " DB20000I  The SQL command completed successfully. 

db2 " update wcs.userreg set PASSWORDRETRIES = 0 where logonid like 'hclu%' "'  db2 " update wcs.userreg set passwordcreation = current timestamp where logonid like 'hclu%' " 

  

update userreg set passwordcreattion = current timestamp, passwordexpired= 0, PASSWORDRETRIES = 0 

 

[db2inst1@COMP-4434-1 ~]$ db2 " update wcs.plcypasswd set MAXLIFETIME = 9999 " 

 

 

db2 "update wcs.userreg set PASSWORDCREATION = current timestamp, PASSWORDEXPIRED = 0 where logonid like 'hcluser%' " 

 

 

[db2inst1@COMP-2228-1 ~]$ db2 "update wcs.userreg set PASSWORDCREATION = current timestamp, PASSWORDEXPIRED = 0, PASSWORDRETRIES = 0 where logonid like 'hcluser%' " 

DB20000I  The SQL command completed successfully. 

[db2inst1@COMP-2228-1 ~]$ 
