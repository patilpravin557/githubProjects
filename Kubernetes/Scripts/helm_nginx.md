**Install Helm:** 

  Find the helm binary download link from [https://github.com/helm/helm/releases](https://github.com/helm/helm/releases)
  
  E.g [https://get.helm.sh/helm-v3.1.3-linux-amd64.tar.gz](https://get.helm.sh/helm-v3.1.2-linux-amd64.tar.gz)
   
  Download the binary with the below 
  
    - curl -O https://get.helm.sh/helm-v3.1.3-linux-amd64.tar.gz
  
  Extract the binary from zip
    
    - tar -xvzf helm-v3.1.2-linux-amd64.tar.gz
  
  Move the helm binary to /usr/local/bin
    
      - mv linux-amd64/helm /usr/local/bin/helm
  
  Verify helm is executable
  
     - helm version
  
 **Install Ngnix** 
 
 Create a name space nginx 
  
    - kubectl create ns nginx 

  NGINX Ingress controller can be installed via Helm

    - helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx 
  
    - helm install my-nginx ingress-nginx/ingress-nginx -n nginx


**Edit Service and update external IP to your machine IP**
  
    kubectl edit service my-nginx-ingress-nginx-controller -n nginx
  
 **Update the external IP as below**

    spec:
    clusterIP: 10.96.8.220
    externalIPs:
    - 10.190.66.215
    externalTrafficPolicy: Cluster
    ports:

   **Verify the  load balancer port is updated in external IP**
   
        [root@COMP-4148-1 ~]# kubectl get services -A
      NAMESPACE     NAME                                          TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
    nginx         my-nginx-ingress-nginx-controller             LoadBalancer   10.98.82.243     10.190.66.215   80:31263/TCP,443:31609/TCP   4m27s
      nginx         my-nginx-ingress-nginx-controller-admission   ClusterIP      10.105.104.122   <none>          443/TCP                      4m27s

      
