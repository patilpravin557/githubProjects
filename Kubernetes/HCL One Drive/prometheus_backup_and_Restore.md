***********************Back up********************************************* 

1.  Get the prometheus object 
[root@com-kube-master ~]# kubectl -n monitoring get prometheus 

NAME                                    VERSION   REPLICAS   AGE 

prometheus-kube-prometheus-prometheus   v2.24.0   1          7d3h 

 

2. Enable admin api 

[root@com-kube-master ~]# kubectl -n monitoring patch prometheus prometheus-kube-prometheus-prometheus --type merge --patch '{"spec":{"enableAdminAPI":true}}' 

prometheus.monitoring.coreos.com/prometheus-kube-prometheus-prometheus patched 

[root@com-kube-master ~]# 

 

3.Check the status of admin api 

[root@com-kube-master ~]# kubectl -n monitoring get sts prometheus-prometheus-kube-prometheus-prometheus -o yaml | grep admin 

        - --web.enable-admin-api 

[root@com-kube-master ~]# 

 

4.Port fwd  

 

kubectl -n monitoring port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 

 

 

ps -ef|grep port-forward 

 

 

5.Take the snapshot  

[root@COMP-4590-1 ~]# curl -XPOST http://127.0.0.1:9090/api/v2/admin/tsdb/snapshot 

{"name":"20210324T103138Z-727a71f52257bb7d"}[root@COMP-4590-1 ~]# 

 

6.snapshot path 

 

[root@COMP-4590-1 snapshots]# pwd 

/kubernetes-pv/local-storage-prometheus/prometheus-db/snapshots 

[root@COMP-4590-1 snapshots]# 

 

 

  

./promethes --storage.tsdb.path=/kubernetes-pv/local-storage-prometheus/prometheus-db/snapshots/20210324T144911Z-3d0d3b628bd49471 --web.listen-address=:9091 

  

./promethes --storage.tsdb.path=/kubernetes-pv/local-storage-prometheus/prometheus-db/snapshots/20210324T144911Z-3d0d3b628bd49471 --web.listen-address=:9091 

 

 

***************Restore********************************************* 

 

 

docker run -p 9090:9090 prom/prometheus 

 

C:\Users\pravinprakash.patil>docker ps 

CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES 

12bfdb304564        prom/prometheus     "/bin/prometheus --c…"   7 hours ago         Up 7 hours          0.0.0.0:9090->9090/tcp   serene_wozniak 

  

 

docker cp C:\Users\pravinprakash.patil\Documents\prometheusdb_snapshot.tar\prometheusdb_snapshot\snapshots\20210329T154039Z-6787bbda69449dbc\01F1A097SZ5ZF1ZFXEES9CD9DJ 12bfdb304564:/prometheus 

 

 

C:\Users\pravinprakash.patil\Downloads>docker exec -it <container_name>  /bin/sh 

/prometheus $     
