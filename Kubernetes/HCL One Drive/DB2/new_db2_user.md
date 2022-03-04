Create new user hh@company.com on the storefront and give it a password diet4coke. All other users will have this same password  

 

db2 "update wcs.userreg set salt = (select salt from wcs.userreg where logonid='hh@company.com') where logonid like 'hclu%' "  

 

db2 "update wcs.userreg set LOGONPASSWORD = (select LOGONPASSWORD from wcs.userreg where logonid='hh@company.com') where logonid like 'hclu%' "  

 

db2 "update wcs.userreg set PASSWORDCREATION = current timestamp, passwordinvalid = NULL, PASSWORDEXPIRED = 0 where logonid like 'hclu%'"  

 

db2 "update wcs.userreg set PLCYACCT_ID = null where logonid like 'hclu%' " 

 

 
