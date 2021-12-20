Setup 
https://boxboat.com/2019/09/03/kubernetes-logging-part-2/ 


## ES

helm repo add elastic https://helm.elastic.co 

helm repo update 

 

THESE ARE TOO  SMALL!!! Select something like 2GB heap ( check memory limit for docker too)  

------------------------------------------------------------------------------------------------ 

# Permit co-located instances for solitary minikube virtual machines. 

antiAffinity: "soft" 

 

# Shrink default JVM heap. 

esJavaOpts: "-Xmx128m -Xms128m" 

 

# Allocate smaller chunks of memory per pod. 

resources: 

  requests: 

    cpu: "100m" 

    memory: "512M" 

  limits: 

    cpu: "1000m" 

    memory: "512M" 

 

# Request smaller persistent volumes. 

volumeClaimTemplate: 

  accessModes: [ "ReadWriteMany" ] 

  storageClassName: "nfs-client" 

  resources: 

    requests: 

      storage: 5000M 

------------------------------------------------ 

 

 

helm install elastic/elasticsearch --name elasticsearch --namespace logging --set replicas=2 --values y 

 

NAME:   elasticsearch 

LAST DEPLOYED: Thu Oct 31 16:02:59 2019 

NAMESPACE: logging 

STATUS: DEPLOYED 

 

RESOURCES: 

==> v1/Pod(related) 

NAME                    READY  STATUS    RESTARTS  AGE 

elasticsearch-master-0  0/1    Init:0/1  0         1s 

elasticsearch-master-1  0/1    Pending   0         1s 

 

==> v1/Service 

NAME                           TYPE       CLUSTER-IP    EXTERNAL-IP  PORT(S)            AGE 

elasticsearch-master           ClusterIP  10.110.49.37  <none>       9200/TCP,9300/TCP  1s 

elasticsearch-master-headless  ClusterIP  None          <none>       9200/TCP,9300/TCP  1s 

 

==> v1/StatefulSet 

NAME                  READY  AGE 

elasticsearch-master  0/2    1s 

 

==> v1beta1/PodDisruptionBudget 

NAME                      MIN AVAILABLE  MAX UNAVAILABLE  ALLOWED DISRUPTIONS  AGE 

elasticsearch-master-pdb  N/A            1                0                    1s 

 

 

NOTES: 

1. Watch all cluster members come up. 

  $ kubectl get pods --namespace=logging -l app=elasticsearch-master -w 

2. Test cluster health using Helm test. 

  $ helm test elasticsearch 


## Elastic - ingress 


kubectl apply -f ingress.yaml 

 

kind: Ingress 

apiVersion: extensions/v1beta1 

metadata: 

  name: elasticsearch-master 

  namespace: logging 

  labels: 

    app: elasticsearch-master 

    heritage: Tiller 

    release: elasticsearch 

spec: 

  rules: 

    - host: elastic.pv 

      http: 

        paths: 

          - path: / 

            backend: 

              serviceName: elasticsearch-master 

              servicePort: 9200 

status: 

  loadBalancer: 

    ingress: 

      - {} 


# Install

helm install kibana elastic/kibana -n es --set ingress.enabled=true --set ingress.hosts[0]=kibana.svt5.hcl.com 

 # Cleanup
  
  helm delete elasticsearch --purge 

kubectl delete pvc elasticsearch-master-elasticsearch-master-0 -n logging 

kubectl get pvc -n logging 

 

 

helm install es-exporter stable/elasticsearch-exporter -n es --set serviceMonitor.enabled=true --set serviceMonitor.namespace=es --set es.uri=http://elasticsearch-master:9200 

 

 

https://github.com/elastic/helm-charts/tree/master/kibana 

 

 

Also look into: 

https://github.com/helm/charts/tree/master/stable/elasticsearch-exporter 

https://grafana.com/grafana/dashboards/2322 

 
