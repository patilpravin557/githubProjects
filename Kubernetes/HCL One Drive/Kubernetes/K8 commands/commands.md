kubectl get nodes 

kubectl get pods 

kubectl create -f <yml file> 

kubectl get replicaset 

kubectl describe replicaset 

kubectl delete pod <pod name> 

kubectl get pods -o wide 

update file---> 

kubectl replace  -f  replicaset-defination.yml 

kubectl scale --replicas=3 replicaset-defination.yml 

kubectl delete replicaset myapp-replicaset 

kubectl get all 

  

Deployment************** 

  

kubectl rollout status deployment/myapp-deployment 

  

kubectl rollout status deployment/myapp-deployment 

  

kubectl rollout history deployment/myapp-deployment 

  

kubectl apply -f deployment-defination.yml 

  

kubectl set image deployment/myapp-deployment 

kubectl rollout undo deployment/myapp-deployment 

  

kubectl run nginx --image=nginx 

it creates pod and deployment 

  

**********summary 

kubectl create -f deployment-defination.yml---create 

kubectl get deployments---get 

kubectl apply -f deployment-defination.yml---update 

kubectl set image deployment/myapp-deployment nginx=nginx:1.9.1 

  

kubectl rollout status deployment/myapp-deployment---status 

kubectl rollout history deployment/myapp-deployment 

  

kubectl rollout undo deployment/myapp-deployment 

  

kubectl create -f deployment-defination.yml --record 

  

***************Prometheus 

docker run -d -p 9090:9090 -v /etc/prometheus/prometheus.yml prom/prometheus -config.file=/etc/prometheus/prometheus.yml -storage.local.path=/prometheus -storage.local.memory-chunks=10000 

  

****************query exporter 

docker run -p 9560:9560/tcp -v /etc/exporter/config.yaml:/config.yaml --rm -it adonato/query-exporter:latest -- /config.yaml 

/etc/exporter 

  

  

******************IBM/ db2 

docker run  --name db2  --privileged=true -d -p 50000:50000 -e LICENSE=accept -e DB2INST1_PASSWORD=db2inst1 -e DBNAME=test -v /home/ubuntu/DB2:/database ibmcom/db2 
  
## view labels
  
  [root@com-kube-master ~]#  kc get deployment demoqaauthts-app -oyaml | grep image 

        image: comlnx94.prod.hclpnp.com/v9hclcache/ts-app:v9-20200910-1635 

        imagePullPolicy: Always 

 

 

 kubectl exec -it demoqalivets-app-6cff684d4f-gvxbw -n commerce -- viewlabels 

 

 

 

[root@com-kube-master ~]# kc get deployment demoqalivequery-app -oyaml | grep image 

        image: comlnx94.prod.hclpnp.com/v9hclcache/search-query-app:v9-20200915-2206 

        imagePullPolicy: Always 

        image: comlnx94.prod.hclpnp.com/9.1/supportcontainer:2.1.0 

        imagePullPolicy: Always 

[root@com-kube-master ~]# kc exec demoqalivequery-app-cd77c4cc8-cw4zm --container query-app  -- viewlabels 

9.1.2.0/search-query-app=v9-20200827-1608 

[root@com-kube-master ~]# 
  
  
  
  
  
  
  kcgp -A -owide | grep 10.34.0.3 

 

kcgp -A -owide | grep comp-3749-1 

 

kcgp -A | grep comp-3749-1 

 

kc logs my-nginx-nginx-ingress-controller-68db5bf9dd-6bv8x --since-time=2020-09-20T09:00:00Z -n default | grep 'timed out' >> nginx_timed_out.log 

 

scp -r /home/db2inst1/db2collect_Script/db2collect.2020-09-21-10.14.59.zip hcluser@10.190.66.145:/home/hcluser/ 

 

 

You can create this pod to see Cache data from Redis using the 'HCL Cache - Remote - Internal' Grafana dashboard: 

 

grep -inr 'hcl-cache' my-values.yaml 

  

[root@com-kube-master es]# cd ~/hclcache/ 
   

[root@com-kube-master hclcache]# kc create -f hcl-cache-app-pod.yaml 
pod/hcl-cache-app created 

 

[root@demoqalivets-app-6677bd4cc8-xqb9p jarfiletoextract]# jar xvf /opt/WebSphere/AppServer/profiles/default/installedApps/localhost/ts.ear/Foundation-Server.jar 

 
    

 

kc get cm demoqaauth-hcl-cache-config  -oyaml 

 

 

*verbose GC 

/opt/WebSphere/AppServer/profiles/default/logs/server1 

[root@com-kube-master ~]# pwd 

/root 

Find / -name "*heap" -print 

kubectl get ingress -A 

 

COPY 

kubectl cp commerce/<pod name>:/opt/WebSphere/AppServer/profiles/default/installedApps/localhost/ts.ear/Foundation-Server.jar ./Foundation-Server.jar 

 

Viewlabels.sh demo qa live 

 

Grep <string> filename 

 

kc logs demoqalivestore-web-7d9d8449b4-zgr9f | grep -v "status\":200" 

 

db2 "SELECT TRUNC_TIMESTAMP( LASTUPDATE , 'HH') AS "hour", COUNT(*) AS "total" FROM WCS.ORDERITEMS WHERE STATUS = 'M' AND lastupdate BETWEEN '2020-06-08-08.28.00.000000' AND '2020-06-08-13.30.00.000000' GROUP BY  TRUNC_TIMESTAMP( LASTUPDATE , 'HH') ORDER BY 1 ASC" 

 

db2 "SELECT TRUNC_TIMESTAMP( LASTUPDATE , 'HH') AS "hour", COUNT(*) AS "total" FROM WCS.ORDERITEMS WHERE STATUS = 'M' AND lastupdate BETWEEN '2020-07-28-07.00.00.000000' AND '2020-07-28-9.10.00.000000' GROUP BY  TRUNC_TIMESTAMP( LASTUPDATE , 'HH') ORDER BY 1 ASC" 

 

[root@com-kube-master ~]# kc scale --replicas=0 deployment demoqalivestore-web -n commerce 

deployment.apps/demoqalivestore-web scaled 

[root@com-kube-master ~]# kc scale --replicas=0 deployment demoqalivets-web  -n commerce 

deployment.apps/demoqalivets-web scaled 

[root@com-kube-master ~]# kc scale --replicas=0 deployment demoqanifi-app  -n commerce 

deployment.apps/demoqanifi-app scaled 

[root@com-kube-master ~]# kc scale --replicas=0 deployment demoqaquery-app  -n commerce 

deployment.apps/demoqaquery-app scaled 

[root@com-kube-master ~]# kc scale --replicas=0 deployment demoqaregistry-app  -n commerce 

deployment.apps/demoqaregistry-app scaled 

[root@com-kube-master ~]# kc scale --replicas=0 deployment demoqatooling-web  -n commerce 

deployment.apps/demoqatooling-web scaled 

[root@com-kube-master ~]# kc get deployments 

 

 

[root@com-kube-master ~]# scale 0 search-query-app 
  adding  search-query-app 
   

[root@com-kube-master ~]# scale 0 ts-app 
  adding  ts-app 
[root@com-kube-master ~]# scale 0 search-nifi-app 
  adding  search-nifi-app 
[root@com-kube-master ~]# scale 0 search-ingest-app 
  adding  search-ingest-app 

 

 

[10:15 PM] Raimee Stevens 

[db2inst1@COMP-2228-1 ~]$ history | grep db2updv 
    1  /opt/ibm/db2/V11.1/bin/db2updv111 -a 
    2  /opt/ibm/db2/V11.1/bin/db2updv111 -d mall -u db2inst1 -p diet4coke -a 
   75  /opt/ibm/db2/V11.1/bin/db2updv111 -d mall -u db2inst1 -p diet4coke -a 
  772  find / -name db2updv* -print 
  773  history | grep db2updv111 
  774   /opt/ibm/db2/V11.1/bin/db2updv111 -d mall -u db2inst1 -p diet4coke -a 
  998  grep history for db2updv 
1000  history | grep db2updv 
[db2inst1@COMP-2228-1 ~]$ 
 
 
  

  

[10:16 PM] Raimee Stevens 

/opt/ibm/db2/V11.1/bin/db2updv111 -d mall -u db2inst1 -p diet4coke -a 
/opt/ibm/db2/V11.1/bin/db2updv111 -d auth -u db2inst1 -p diet4coke -a 
 
  

 

 

kc logs demoqaauthstore-web-6b589bf595-zshrs 

 

helm uninstall demo-qa-share . -f my-values.yaml --set common.environmentType=share -n commerce --debug -v 10 

 

kubectl get po -n commerce | awk '{if ($3 ~ /Completed/) system ("kubectl -n " $1 " delete pods " $2)}' 

 

 

kubectl get po --all-namespaces | awk '{if ($4 ~ /Evicted/) system ("kubectl -n " $1 " delete pods " $2)}' 

 

ssh comp-3748-1 

 

helm install demo-qa-share . -f my-values.yaml --set common.environmentType=share -n commerce --debug -v 10 | tee out.log 

  

kc get jobs -n commerce 

 

tail -n 10 nifi.logs 

 

kubectl delete jobs $(kubectl get jobs -o custom-columns=:.metadata.name) 

 

kubectl get all | awk '/job.batch/ {print $1}' | xargs kubectl delete 

 

kubectl get all | awk '/demoqalivequery-app/ {print $1}' | xargs kubectl delete 

 

history | grep "helm inst" 

 

find . -name tecmint.txt 

find / -type d -name Tecmint 
