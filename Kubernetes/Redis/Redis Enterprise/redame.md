
# Redis Enterprise 

 

https://github.com/RedisLabs/redis-enterprise-k8s-docs 

 

git clone https://github.com/RedisLabs/redis-enterprise-k8s-docs 

 

Edit crds/app_v1_redisenterprisecluster_cr.yaml  
================================== 

apiVersion: app.redislabs.com/v1 

kind: RedisEnterpriseCluster 

metadata: 

  name: "redis-enterprise" 

spec: 

  # Add fields here 

  nodes: 1 

  persistentSpec: 

    enabled: false 

  redisEnterpriseNodeResources: 

    limits: 

      cpu: "8" 

      memory: 16Gi 

    requests: 

      cpu: "2" 

      memory: 8Gi 

================================== 

  

kubectl create namespace redislabs 

kubectl apply -f bundle.yaml -n redislabs 

kubectl apply -f crds/app_v1_redisenterprisecluster_cr.yaml -n redislabs 

 

========================================== 

echo `kubectl get secret redis-enterprise -n redislabs -o jsonpath="{.data.username}" | base64 --decode` 

demo@redislabs.com 
 
echo `kubectl get secret redis-enterprise -n redislabs -o jsonpath="{.data.password}" | base64 --decode` 

lA4CfZsr 

 

 

 

 

demo@redislabs.com 

lA4CfZsr 

 

===================================================== 

kubectl port-forward redis-enterprise-0 -n redislabs 8443:8443 & 

 

In the console, 

Add this under general/settings/cluster key 
 
 

License Owner: SA_POC_TRIAL 

Cluster Name : <any> 

Shards limit : 500 

Valid        : 2020-05-15T00:00:00Z-2020-07-01T00:00:00Z 

Features     : trial 

  

----- LICENSE START ----- 

mv13QWi6rU0qgctMyQshpfEjoCbR/3EEySWtVLdOPNg8w+vI6MHVvrIuZHlv 

FH9E7j0PMj3h6Op5XrL6n1Dmk5N84jFg/NXkucKe/D8XqqCfd7caCd+irBR8 

HL8TlV9BamrKMV2OleF6lhlJ69/hWrp1u66YVAwWEO7aBiNoXhFVZu1dJYcL 

t9UondKSbJTns1G0juzZ+ZmGBFb6Lb/klsnJyqxU9kJzF1bxjJEhovab/ZI3 

meQTTe2g189UYvIJFFHjfk/AW4QC9FCkJWypWOdk05BYCr4didsh/Ic9I/XL 

77UNRkKo6pYcaUqzorWo6IwzFJybDibbNPYn7hlvyA== 

----- LICENSE END ----- 
 
 

 

 

redis-cli -h 192.168.109.214 -p 10803 -a admin dbsize 

for i in `seq 1 3000`; do redis-cli -h 192.168.109.214 -p 10803 -a admin "set" "key_{key1}_$i" `tr -dc A-Za-z0-9 </dev/urandom | head -c 1000`; done 

 

 

 

 

 

Uninstall 

kubectl delete rec redis-enterprise -n redislabs 

kubectl delete namespace redislabs 

 

 

 

 

echo `kubectl get secret redis-enterprise -n redislabs -o jsonpath="{.data.username}" | base64 --decode` 

demo@redislabs.com 
 
echo `kubectl get secret redis-enterprise -n redislabs -o jsonpath="{.data.password}" | base64 --decode` 

n2GWIsHd 

 

 

kubectl port-forward service/redis-enterprise-ui -n redislabs 8443:8443 
