Install Oracle 

Copy the zipped install image under $ORACLE_HOME 

./runInstaller 

Create and configure the db 

Server class 

Enterprise edition 

Oracle base = /u01/app/oracle/ 

Standard installation - Typical 

Global db = mall.nonprod.hclpnp.com 

password = wcs1 

no pluggable db  

Oracle inventory = /u01/app/oraInventory 

oraInventory group name = oinstall 

 
Create initmall.ora  

Go under $ORACLE_HOME/dbs and create initmall.ora with the following content 

db_name='mall' 

memory_target=1G 

processes = 150 

audit_file_dest='$ORACLE_BASE/admin/mall/adump' 

audit_trail ='db' 

db_block_size=8192 

db_domain='' 

db_recovery_file_dest='$ORACLE_BASE/fast_recovery_area' 

db_recovery_file_dest_size=2G 

diagnostic_dest='$ORACLE_BASE/diagnostic' 

dispatchers='(PROTOCOL=TCP) (SERVICE=MALL)' 

open_cursors=300 

remote_login_passwordfile='EXCLUSIVE' 

undo_tablespace='UNDOTBS1' 

control_files = (ora_control1, ora_control2) 

Ensure you have 1G memory available, otherwise lower the number of memory_target parameter to 500M or so  

Ensure you have all the paths in initmall.ora created  

 

Delete the db created during installation  

Check the files of the db already created.  

$ sqlplus / as sysdba 

  SQL> select name from v$datafile; 

        NAME 

        -------------------------------------------------------------------------------- 

        /u01/app/oracle/oradata/mall/system01.dbf 

        /u01/app/oracle/oradata/mall/sysaux01.dbf 

        /u01/app/oracle/oradata/mall/undotbs01.dbf 

        /u01/app/oracle/oradata/mall/users01.dbf 

     

  SQL> select name from v$controlfile; 

        NAME 

        -------------------------------------------------------------------------------- 

        /u01/app/oracle/oradata/mall/control01.ctl 

        /u01/app/oracle/oradata/mall/control02.ctl 

  

  SQL> select member from v$logfile; 

        MEMBER 

        -------------------------------------------------------------------------------- 

        /u01/app/oracle/oradata/mall/redo03.log 

        /u01/app/oracle/oradata/mall/redo02.log 

        /u01/app/oracle/oradata/mall/redo01.log 

  

  SQL> shutdown immediate; 

  SQL> startup mount exclusive restrict; 

  SQL> drop database; 

 Check the folders shown in the previous queries results and if they still there, delete them all.  

 

Update your .bash_profile for oracle userid and add the following  

        # Oracle variables 

        export TMP=/tmp 

        export TMPDIR=$TMP 

        export ORACLE_HOSTNAME=<your hostname> 

        export ORACLE_BASE=/u01/app/oracle 

        export ORACLE_HOME=<your oracle home> 

        export ORA_INVENTORY=/u01/app/oraInventory 

        export ORACLE_SID=mall 

        export DATA_DIR=/u02/oradata 

  

        PATH=$PATH:$ORACLE_HOME/bin:$HOME/.local/bin:$HOME/bin 

        export PATH 

  

        export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib 

        export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib 

 

Prepare the files to create Commerce db 

Go under $ORACLE_HOME/network/admin and create the following 2 filename with this contents  
Respect the indentation of the content 

 
File tnsnames.ora 

        LISTENER_MALL = 

            (ADDRESS = (PROTOCOL = TCP)(HOST = 10.190.67.41)(PORT = 1521)) 

        MALL = 

            (DESCRIPTION = 

                (ADDRESS = (PROTOCOL = TCP)(HOST = 10.190.67.41)(PORT = 1521)) 

                (CONNECT_DATA = 

                    (SERVER = DEDICATED) 

                    (SERVICE_NAME = mall.nonprod.hclpnp.com) 

                ) 

            ) 

 

File listener.ora 

        LISTENER = 

           (DESCRIPTION_LIST = 

               (DESCRIPTION = 

                   (ADDRESS = (PROTOCOL = TCP)(HOST = 10.190.67.41)(PORT = 1521)) 

                   (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1522)) 

               ) 

           ) 

 
Exit your oracle's session and connect back to set all the variables in .bash_profile  

 

Create Oracle Commerce database 

Go to sqlplus by running 

$ sqlplus / as sysdba  

and run the following sql (ensure the paths in the sql exist already) 

SQL> create database mall user sys identified by passw0rd user system identified by passw0rd logfile group 1 ('/u01/app/oracle/oradata/mall/redo01.log') size 100m, group 2  ('/u01/app/oracle/oradata/mall/redo02.log') size 100m, group 3 ('/u01/app/oracle/oradata/mall/redo03.log') size 100m maxlogfiles 5 maxlogmembers 5 maxloghistory 1 maxdatafiles 100 maxinstances 1 character set al32utf8 datafile '/u01/app/oracle/oradata/mall/system01.dbf' size 325m reuse autoextend on next 100m maxsize unlimited,  '/u01/app/oracle/oradata/mall/system02.dbf' size 325m reuse autoextend on next 100m maxsize unlimited, '/u01/app/oracle/oradata/mall/system03.dbf' size 325m reuse autoextend on next 100m maxsize unlimited sysaux datafile '/u01/app/oracle/oradata/mall/sysaux01.dbf' size 325m reuse autoextend on extent management local default tablespace wcs_t datafile '/u01/app/oracle/oradata/mall/wcs_t.dbf' size 100m reuse autoextend on next 100m maxsize unlimited default temporary tablespace wcs_temp_t tempfile '/u01/app/oracle/oradata/mall/wcs_temp_t.dbf' size 100m reuse autoextend on next 100m maxsize unlimited undo tablespace undotbs1 datafile '/u01/app/oracle/oradata/mall/undotbs1.dbf' size 200m reuse autoextend on next 5120k maxsize unlimited; 

 

Create Oracle views and tables 

Go to sqlplus and run the following sql files 

SQL> @$ORACLE_HOME/rdbms/admin/catalog.sql 

SQL> @$ORACLE_HOME/rdbms/admin/catproc.sql 

SQL> @$ORACLE_HOME/sqlplus/admin/pupbld.sql 

 

Create users 

SQL> shutdown immediate 

SQL> startup 

SQL> alter session set "_ORACLE_SCRIPT"=true;  

SQL> CREATE USER wcs IDENTIFIED BY wcs1 DEFAULT TABLESPACE wcs_t TEMPORARY TABLESPACE wcs_temp_t QUOTA UNLIMITED ON wcs_t; 

SQL> GRANT CREATE PROCEDURE, CREATE SEQUENCE, CREATE SESSION, CREATE SYNONYM, CREATE TABLE, CREATE TRIGGER, CREATE VIEW, CREATE MATERIALIZED VIEW TO wcs; 

SQL> alter session set "_ORACLE_SCRIPT"=false;  

 

Prepare the db to be used by Commerce 

SQL> purge dba_recyclebin; 

SQL> shutdown immediate; 

SQL> startup mount; 

SQL> alter system set max_string_size=extended scope=spfile; 

SQL> shutdown; 

SQL> startup upgrade; 

SQL> @?/rdbms/admin/utl32k.sql  

SQL> show parameter max_string_size 

    NAME                    TYPE        VALUE 

    ---------------------- ----------- -------------- 

    max_string_size   string      EXTENDED 

 

SQL> shutdown immediate; 

SQL> startup; 

 

Configure connectivity  

SQL> show parameter local_listener 

        NAME                                      TYPE        VALUE 

        ------------------------------------ ----------- ------------------------------ 

        local_listener                          string 

 

SQL> alter system set local_listener='(ADDRESS=(PROTOCOL=TCP)(HOST=xx.xx.xx.xx)(PORT=1521))' scope=both sid='*'; 

SQL> alter system register; 

SQL> show parameter local_listener; 

        NAME                                      TYPE        VALUE 

        ------------------------------------ ----------- ------------------------------ 

        local_listener                          string      (ADDRESS=(PROTOCOL=TCP)(HOST=xx.xx.xx.xx)(PORT=1521)) 

 

SQL> alter system set local_listener='LISTENER_MALL' scope=both sid='*'; 

 

Ensure the listener is restarted. Check its status and start it if it's down.  
   $ lsnrctl status 

   $ lsnrctl start  

You can also restart it by  
   $ lsnrctl reload  

 

Create Commerce schema and load bootstrap data 

docker exec -it bvt_utils_1 bash 

cd /opt/WebSphere/CommerceServer90/bin 

Run the following command to load bootstrap data 
./initdb_oracle_sample.sh staging mall <db server ip addr> 1521 system passw0rd wcs wcs1 1234567890abcdef1234567890abcdef 3h8x876vd8g3 wcs1admin 3h8x876vd8g3 passw0rd sampleData 
 
The complete syntax is like this  
initdb_oracle_sample.bat <type> <dbName> <dbServer> <dbPort> <dbaUser> <dbaPassword> <dbUser> <dbPassword> <merchantKey> <wcsadminSalt> <wcsadminPassword> <spiuserSalt> <spiuserPassword> <withSample> <sslKeyFile> <sslKeyPassword> 
