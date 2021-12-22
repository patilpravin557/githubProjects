import os
cellName = "localhost"
nodeName = "localhost"
serverName = "server1"
HPELService = AdminConfig.getid("/Cell:%s/Node:%s/Server:%s/HighPerformanceExtensibleLogging:/"%(cellName,nodeName,serverName))
AdminConfig.modify(HPELService, "[[enable true]]")
RASLogging = AdminConfig.getid("/Cell:%s/Node:%s/Server:%s/RASLoggingService:/"%(cellName,nodeName,serverName))
AdminConfig.modify(RASLogging, "[[enable false]]")
AdminConfig.save()
