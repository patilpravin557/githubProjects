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
