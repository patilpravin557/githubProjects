Liberty 

 

COPY logging.xml /opt/WebSphere/Liberty/usr/servers/default/configDropins/overrides/logging.xml 
 
 
 

 

Trace.log location 

/opt/WebSphere/Liberty/usr/servers/default/logs/container/ESQuery_demoqalivequery-app-6fd85856fb-j2hxg 

 

 

Before 

<server> 

  <logging suppressSensitiveTrace="true" traceFormat="BASIC" traceSpecification="*=info" traceFileName="stdout" hideMessage="SRVE9967W"> 

    <binaryLog purgeMaxSize="1024" purgeMinTime="168" outOfSpaceAction="PurgeOld" fileSwitchTime="0"/> 

    <binaryTrace purgeMaxSize="1024" purgeMinTime="168" outOfSpaceAction="PurgeOld" fileSwitchTime="0"/> 

  </logging> 

</server> 

 

 

After 

<server> 

  <logging suppressSensitiveTrace="true" traceFormat="BASIC" traceSpecification="com.hcl.commerce.cache*=all" traceFileName="trace.log" hideMessage="SRVE9967W"> 

    <binaryLog purgeMaxSize="1024" purgeMinTime="168" outOfSpaceAction="PurgeOld" fileSwitchTime="0"/> 

    <binaryTrace purgeMaxSize="1024" purgeMinTime="168" outOfSpaceAction="PurgeOld" fileSwitchTime="0"/> 

  </logging> 

</server> 

 

TS-APP 

 

[root@demoqalivets-app-5564954b44-2vkx7 ~]# run set-dynamic-trace-specification com.hcl.commerce.cache*=all 
WASX7209I: Connected to process "server1" on node localhost using SOAP connector; The type of process is: UnManagedProcess 
Trace Specification is set to com.hcl.commerce.cache*=all. 

 

 

run set-dynamic-trace-specification *=info:com.ibm.commerce.cf.datatype.*=all 

run reset-dynamic-trace-specification 

 

*=info:com.ibm.commerce.cf.datatype.*=all 

 

*=info:com.ibm.commerce.cf.datatype.LocalHclCache.*=all 

 

 

run reset-dynamic-trace-specification *=info:com.ibm.commerce.cf.datatype.*=all 

 

com.ibm.commerce.cf.datatype.LocalHclCache=all  

 

[root@demoqalivets-app-59fcddcb54-ljgcf /]# run set-dynamic-trace-specification *=info:com.ibm.commerce.cf.datatype.*=all 
WASX7209I: Connected to process "server1" on node localhost using SOAP connector; The type of process is: UnManagedProcess 
Trace Specification is set to *=info:com.ibm.commerce.cf.datatype.*=all. 

 

 

 

[root@demoqalivets-app-758d8cc8d-skw8l /]# run set-dynamic-trace-specification *=info:com.ibm.commerce.cf.datatype.LocalHclCache.*=all 

WASX7209I: Connected to process "server1" on node localhost using SOAP connector;  The type of process is: UnManagedProcess 

Trace Specification is set to *=info:com.ibm.commerce.cf.datatype.LocalHclCache.*=all. 

 

 

   - name: JDBC_MONITOR_ENABLED 
      value: "true" 
    - name: TRACE_SPEC 
      value: com.hcl.commerce.monitor.jdbc.JDBCMonitor=fine 
 
