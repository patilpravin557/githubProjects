[root@com-kube-master ~]# kubectl -n monitoring get prometheus 

NAME                                    VERSION   REPLICAS   AGE 

prometheus-kube-prometheus-prometheus   v2.24.0   1          7d3h 

 

 

[root@com-kube-master ~]# kubectl -n monitoring patch prometheus prometheus-kube-prometheus-prometheus --type merge --patch '{"spec":{"enableAdminAPI":true}}' 

prometheus.monitoring.coreos.com/prometheus-kube-prometheus-prometheus patched 

[root@com-kube-master ~]# 

 

 

 

[root@com-kube-master ~]# kubectl -n monitoring get sts prometheus-prometheus-kube-prometheus-prometheus -o yaml | grep admin 

        - --web.enable-admin-api 

[root@com-kube-master ~]# 

 

kubectl -n monitoring port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 

  

ps -ef|grep port-forward 

 

Kill –9 pid 

 

root@COMP-4590-1 ~]# curl -XPOST http://127.0.0.1:9090/api/v2/admin/tsdb/snapshot 

{"name":"20210324T103138Z-727a71f52257bb7d"}[root@COMP-4590-1 ~]# 

 

root@com-kube-master ~]# curl -XPOST http://127.0.0.1:9090/api/v1/admin/tsdb/snapshot 

{"status":"success","data":{"name":"20210324T142140Z-659b37d8e321bc52"}}[root@com-kube-master ~]# 

 

[root@COMP-4590-1 snapshots]# pwd 

/kubernetes-pv/local-storage-prometheus/prometheus-db/snapshots 

 

 

curl http://127.0.0.1:9090/metrics 
