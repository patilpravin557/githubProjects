https://jorgedelacruz.uk/2019/09/27/grafana-using-microsoft-teams-for-our-notifications-when-established-thresholds-are-exceeded/ 

 

 

# Please edit the object below. Lines beginning with a '#' will be ignored, 

# and an empty file will abort the edit. If an error occurs while saving this file will be 

# reopened with the relevant failures. 

# 

apiVersion: v1 

data: 

  grafana.ini: | 

    [analytics] 

    check_for_updates = true 

    [grafana_net] 

    url = https://grafana.net 

    [log] 

    mode = console 

    [paths] 

    data = /var/lib/grafana/data 

    logs = /var/log/grafana 

    plugins = /var/lib/grafana/plugins 

    provisioning = /etc/grafana/provisioning 

    [smtp] 

    enabled = true 

    host = "grafana.local" 

    user = "admin" 

    password = "prom-operator" 

kind: ConfigMap 

metadata: 

  creationTimestamp: "2020-03-10T16:53:01Z" 

  labels: 

    app.kubernetes.io/instance: prometheus 

    app.kubernetes.io/managed-by: Tiller 

    app.kubernetes.io/name: grafana 

    app.kubernetes.io/version: 6.6.1 

    helm.sh/chart: grafana-5.0.0 

  name: prometheus-grafana 

  namespace: monitoring 

  resourceVersion: "2832" 

  selfLink: /api/v1/namespaces/monitoring/configmaps/prometheus-grafana 

  uid: 94e1d342-168b-47bf-a3d1-2c0f96694650 

 
Meantime the application issue got resolved...just for the learning purpose....I have tried to set up grafana alert for redis cluster.. 

  

1. Set up the notification channel as Microsoft Teams as Andres mentioned in the group 
2. While configuring teams at grafana side, faced SMTP error (SMTP not configured, check your grafana.ini config file's [smtp] section) 
3. Enabled SMTP configuration at grafana side and issue has been resolved. 
4. Test notification has been send to Teams Successfully from grafana  
5. 5. I have imported Andres dashboard in my env for setting the alert. 
6. Here I have observed while setting the alerts on template variables, it is not allowing me to create an alert, giving below error ,not sure how to tackle this , still searching  
7.  I have changed the variables settings to all though 
8.   So tried to set up the alert rule for plan query without variables and did not observe any error, rule has been successfully validated and received team notification for the defined rule 
