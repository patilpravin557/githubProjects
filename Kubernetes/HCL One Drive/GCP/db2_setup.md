yum -y install libstdc++ 
    yum -y install libstdc++.i686 
    yum -y install dapl 
    yum -y install sg3_utils 
    yum -y install sg_persist 
    yum -y install gnome-session  
    yum -y install xterm 
    yum -y install xhost 
    yum -y install tigervnc-server 
    yum -y install ksh 
    yum -y install pam-devel.i686  

db2licm -a /tmp/db2licm_o.lic 

 [root@perf-cluster-1-db2-1 universal]# yum install libstdc++ 
• [root@perf-cluster-1-db2-1 universal]# yum install libaio 
• [root@perf-cluster-1-db2-1 universal]# yum install gcc-c++ 

 

 

 

root@perf-cluster-2-db2 server_dec]# ./db2setup -r /home/db2rsp/db2server.rsp 
Requirement not matched for DB2 database "Server" . Version: "11.5.0.0". 

Summary of prerequisites that are not met on the current system: 

DBT3514W The db2prereqcheck utility failed to find the following 32-bit library file: "/lib/libpam.so*". 

 
DBT3609E The db2prereqcheck utility could not find the library file libnuma.so.1. 

 
DBT3514W The db2prereqcheck utility failed to find the following 32-bit library file: "libstdc++.so.6". 

 
Aborting the current installation ... 
Run installation with the option "-f sysreq" parameter to force the installation. 
[root@perf-cluster-2-db2 server_dec]# 
