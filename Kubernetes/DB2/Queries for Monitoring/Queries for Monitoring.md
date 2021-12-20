## Queries for Monitoring 

 

https://hub.docker.com/r/adonato/query-exporter 

https://github.com/albertodonato/query-exporter 

 

 

Workload summary 

 
-- https://www.ibm.com/support/knowledgecenter/SSEPGG_11.5.0/com.ibm.db2.luw.sql.rtn.doc/doc/r0060767.html 

-- LOCK_WAIT IDLE ACQUIRE LOCK 

-- ESCALATION EXECUTING PROCESS LOCK_ESCALATION  

-- UOW_EXECUTE EXECUTING PROCESS REQUEST 

-- UOW_WAIT IDLE WAIT       REQUEST 

 

SELECT SUM(pool_data_l_reads) AS pool_data_l_reads, SUM(pool_index_l_reads) AS pool_index_l_reads, SUM(pool_temp_data_l_reads) AS pool_temp_data_l_reads, SUM(pool_temp_index_l_reads) AS pool_temp_index_l_reads, SUM(pool_data_p_reads) AS pool_data_p_reads  SUM(pool_index_p_reads) AS pool_index_p_reads, SUM(pool_temp_data_p_reads) AS pool_temp_data_p_reads, SUM(pool_temp_index_p_reads) AS pool_temp_index_p_reads, SUM(pool_data_writes) AS pool_data_writes, SUM(pool_index_writes) AS pool_index_writes, SUM(pool_read_time) AS pool_read_time, SUM(pool_write_time) AS pool_write_time, SUM(client_idle_wait_time) AS client_idle_wait_time, SUM(deadlocks) AS deadlocks, SUM(direct_reads) AS direct_reads,SUM(direct_read_time) AS direct_read_time, SUM(direct_writes) AS direct_writes, SUM(direct_write_time) AS direct_write_time, SUM(direct_read_reqs) AS direct_read_reqs, SUM(direct_write_reqs) AS direct_write_reqs, SUM(lock_escals) AS lock_escals, SUM(lock_timeouts) AS lock_timeouts, SUM(lock_wait_time) AS lock_wait_time, SUM(lock_waits) AS lock_waits, SUM(log_buffer_wait_time) AS log_buffer_wait_time, SUM(num_log_buffer_full) AS num_log_buffer_full, SUM(log_disk_wait_time) AS log_disk_wait_time, SUM(log_disk_waits_total) AS log_disk_waits_total, SUM(rqsts_completed_total) AS rqsts_completed_total, SUM(rows_modified) AS rows_modified, SUM(rows_read) AS rows_read, SUM(rows_returned) AS rows_returned, SUM(tcpip_recv_volume) AS tcpip_recv_volume, SUM(tcpip_send_volume) AS tcpip_send_volume, SUM(tcpip_recv_wait_time) AS tcpip_recv_wait_time,  SUM(tcpip_recvs_total) AS tcpip_recvs_total, SUM(tcpip_send_wait_time) AS tcpip_send_wait_time, SUM(tcpip_sends_total) AS tcpip_sends_total, SUM(total_rqst_time) AS total_rqst_time, SUM(CAST((total_cpu_time/1000) AS BIGINT)) AS total_cpu_time_ml, SUM(total_wait_time) AS total_wait_time, SUM(total_section_sort_time) AS total_section_sort_time, SUM(total_sorts) AS total_sorts, SUM(sort_overflows) AS sort_overflows, SUM(total_commit_time) AS total_commit_time, SUM(total_app_commits) AS total_app_commits,  SUM(total_rollback_time) AS total_rollback_time, SUM(total_app_rollbacks) AS total_app_rollbacks, SUM(total_runstats_time) AS total_runstats_time, SUM(total_runstats) AS total_runstats, SUM(total_reorg_time) AS total_reorg_time, SUM(total_reorgs) AS total_reorgs, SUM(total_load_time) AS total_load_time, SUM(total_loads) AS total_loads, SUM(pkg_cache_inserts) AS pkg_cache_inserts, SUM(pkg_cache_lookups) AS pkg_cache_lookups 

  FROM TABLE(mon_get_workload('',-1)) AS w  

 GROUP BY workload_name 

 

 

Connections by status 

 
 

-- https://www.ibm.com/support/knowledgecenter/SSEPGG_11.5.0/com.ibm.db2.luw.sql.rtn.doc/doc/r0060767.html 

-- LOCK_WAIT IDLE ACQUIRE LOCK 

-- ESCALATION EXECUTING PROCESS LOCK_ESCALATION  

-- UOW_EXECUTE EXECUTING PROCESS REQUEST 

-- UOW_WAIT IDLE WAIT       REQUEST 

 

SELECT appl_status, SUM( total ) total 

FROM ( 

SELECT  

DECODE( event_state || event_type || event_object, 

'IDLEACQUIRELOCK',   'LOCK_WAIT', 

'EXECUTINGPROCESSLOCK_ESCALATION','LOCK_ESCALATION', 

'EXECUTINGPROCESSREQUEST',   'UOW_EXECUTE', 

'IDLEWAITREQUEST',       'UOW_WAIT', 

'EXECUTINGPROCESSROUTINE',        'ROUTINE', 

'OTHER' ) appl_status, 

         1 total 

FROM TABLE(MON_GET_AGENT('SYSDEFAULTUSERCLASS', 'SYSDEFAULTSUBCLASS', NULL, -2)) 

WHERE MON_GET_APPLICATION_HANDLE() <> application_handle 

      UNION ALL     

      SELECT 'LOCK_WAIT' appl_status, 0 total FROM sysibm.sysdummy1 

      UNION ALL     

      SELECT 'LOCK_ESCALATION' appl_status, 0 total FROM sysibm.sysdummy1 

      UNION ALL     

      SELECT 'UOW_EXECUTE' appl_status, 0 total FROM sysibm.sysdummy1 

      UNION ALL     

      SELECT 'UOW_WAIT' appl_status, 0 total FROM sysibm.sysdummy1  

      UNION ALL     

      SELECT 'ROUTINE' appl_status, 0 total FROM sysibm.sysdummy1 ) 

GROUP BY appl_status 

 

 

Connections in Lock wait Details  
 

SELECT tabname,  

   CAST(req_stmt_text AS VARCHAR(512)) req_stmt_text,  

   SUM(lock_wait_elapsed_time) lock_wait_elapsed_time, 

   COUNT(*) total_connections_lock_wait 

  FROM sysibmadm.mon_lockwaits 

 GROUP BY tabname, CAST(req_stmt_text AS VARCHAR(512)) 

 

 

Orders by Status 
 

SELECT status, COUNT(*) total_orders 

  FROM wcs.orders 

 GROUP BY status 

  WITH UR 

 

Order Items 
 

SELECT COUNT(*) total_orderitems 

  FROM wcs.orderitems 

  WITH UR 

 # db2
 
 /* https://www.ibm.com/support/knowledgecenter/SSEPGG_11.1.0/com.ibm.db2.luw.sql.rtn.doc/doc/r0022011.html */ 

SELECT APPL_STATUS, COUNT(*) AS "COUNT" 

 FROM SYSIBMADM.APPLICATIONS  

WHERE MON_GET_APPLICATION_HANDLE() <> AGENT_ID 

 GROUP BY APPL_STATUS 

  

  

  

SELECT COUNT(*) AS TOTAL, 

SUM( DECODE( APPL_STATUS, 'LOCKWAIT', 1, 0 )) AS LOCKWAIT, 

SUM( DECODE( APPL_STATUS, 'UOWEXEC', 1, 0 )) AS UOWEXEC, 

SUM( DECODE( APPL_STATUS, 'UOWWAIT', 1, 0 )) AS UOWWAIT, 

SUM( DECODE( APPL_STATUS, 'COMMIT_ACT', 1, 0 )) AS COMMIT_ACT, 

SUM( DECODE( APPL_STATUS, 'CONNECTED', 1, 0 )) AS CONNECTED 

 FROM SYSIBMADM.APPLICATIONS  

WHERE MON_GET_APPLICATION_HANDLE() <> AGENT_ID 

  

 

 

 

 

 

 

 

 
