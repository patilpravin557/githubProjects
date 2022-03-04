https://github02.hclpnp.com/commerce-dev/commerce-helmchart 

 

gcloud container clusters get-credentials perf-cluster2-ingest --zone us-east1-b --project commerce-product 

kubectl config set-context --current --namespace=commerce 

 

 

# helm delete -n elastic elasticsearch 

# helm delete -n elastic kibana 

# helm delete -n zookeeper zookeeper 

# helm delete -n redisc redis 

# helm delete -n vault vault 

# helm delete -n commerce demo-qa-share 

#helm delete -n commerce demo-qa-auth 

# helm delete -n commerce demo-qa-live 

 

Remove images from the gcp machine and docker puch machines  

 

CHANGES MADE in Values.yaml file in commerce tag ahas been change to date plese check before deploying 

 

Nifi crashes with below errror add into vault 

 

[2021-07-06 14:45:42 GMT] ERROR: 'ADMIN_SPIUSER_PWD' is not specified 

 

[06-07-2021 20:30] Pravin Prakash Patil 

adminSpiUserPwd what its value  

 

qa/adminSpiUserPwd 

 

Value  passw0rd 
 

[06-07-2021 20:31] Pravin Prakash Patil 

curl -k -sS -u spiuser:passw0rd -X GET this one  


Upload all bvt images from nexux to gcp repo with latest release 

 

 

C:\Users\pravinprakash.patil\Documents\gcp_commerce\commerce-helmchart-master\commerce-helmchart-master\hcl-commerce-helmchart\sample_values 

 

    helm install elasticsearch elastic/elasticsearch -f .\elasticsearch-values.yaml -n elastic 

     

    helm install zookeeper bitnami/zookeeper -n zookeeper -f .\zookeeper-values.yaml 

 

C:\Users\pravinprakash.patil\Documents\gcp_commerce\commerce-helmchart-master\commerce-helmchart-master\hcl-commerce-helmchart\sample_values\Raimee 

 

    helm install redis stable/redis -f .\redis-values.yaml -n redisc 

 

C:\Users\pravinprakash.patil\Documents\gcp_commerce\commerce-helmchart-master\commerce-helmchart-master 

 

 helm install vault hcl-commerce-vaultconsul-helmchart/stable/hcl-commerce-vaultconsul/ -n vault -f hcl-commerce-vaultconsul-helmchart/stable/hcl-commerce-vaultconsul/values.yaml 

 

 

C:\Users\pravinprakash.patil\Documents\gcp_commerce\commerce-helmchart-master\commerce-helmchart-master\hcl-commerce-helmchart\stable\hcl-commerce 

 

  helm install demo-qa-share . -f values.yaml --set common.environmentType=share -n commerce  

 

  helm install demo-qa-auth . -f values.yaml --set common.environmentType=auth -n commerce 

 

  helm install demo-qa-live . -f values.yaml --set common.environmentType=live -n commerce 

 

 

 

2. In the computer that has kubectl tools installed, use: `kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user <_user-account_>` 

  

Only after you have read and understand the GCP clusterrolebinding then proceed with the following steps. 

  

3. Download [clusterrole.yaml](clusterrole.yaml) 

  

kind: ClusterRole 

apiVersion: rbac.authorization.k8s.io/v1 

metadata: 

  name: wcs-psp 

rules: 

  - apiGroups: 

    - extensions 

    resources: 

    - podsecuritypolicies 

    resourceNames: 

    - commerce-psp 

    verbs: 

    - use 

  

4. `kubectl create -f clusterrole.yaml` 
