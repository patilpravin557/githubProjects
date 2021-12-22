# Commerce

**Pre-requisite**  : Helm, Vault, Nginx, Kafka, Zookeeper, Elastic Search and Prometheus is installed

1) Download the latest helmchart : [https://github02.hclpnp.com/commerce-dev/commerce-helmchart/blob/master/hcl-commerce-helmchart/stable/hcl-commerce/values.yaml](https://github02.hclpnp.com/commerce-dev/commerce-helmchart/blob/master/hcl-commerce-helmchart/stable/hcl-commerce/values.yaml)

2) Unzip the helmchart file

3) Switch to **hcl-commerce-helmchart/stable/hcl-commerce**  directory

4) Modify  my-values.yaml  or Create a new file .  (Incase of re-deployment always compare and copy the changes in your values.yaml file )

    1. Edit my-values.yaml file
    1. Update  **license**  to  **accept**
   2. Under common:
    1. Update  **vaultTokenSecret**  to  **vault-token-secret**
    2. Update  **tenant**  to match to the one you used in vault deployment – Usually its value is demo .
    3. Update  **imageRepo**  to  **comlnx94.prod.hclpnp.com/**
    4. Update  **spiUser\* ** values if needed
    5. Update  **vaultUrl**  to [http://vault-consul.vault.svc.cluster.local:8200/v1](http://vault-consul.vault.svc.cluster.local:8200/v1). Note vault before .svc is the namespace where you deploy your vault. If you deployed vault in a different name space, change it to the correct value.
    6. Update  **bindingConfigMap**  to empty string
    7. **Update externalDomain if needed. This domain is used in ingress so that you can hit the service from outside of the cluster. E.g it has .mycompany.com as the default value, and then the ingress will use some sub domains to access the store and tooling, e.g cmc.demoqaauth.mycompany.com will be used to access cmc tooling after we map this domain to the ingress IP in our local host file.  I have used .nidhicompany.com** _
    8. Make sure  **configureMode**  is set to Vault
    9. Leave imagePullSecrets empty as our comlnx94 registry is not authenticated
    10. Set  **imagePullPolicy**  to  **Always**  if you want to use  **v9-latest**  tags so that it always pulls the latest images before deploy, or leave it as  **IfNotPresent**  if you use the specific tag for docker images.
  3. Under createSampleConfig:
 
 1. Set  **enable**  to  **false** , as we do not want to use un-supported configuration mode

4. Under vaultCA:
  
   1. Make sure  **enable**  is set to  **true**
   
5. Under tsDb:
    1. If you plan to use the database running outside of the k8s cluster, set the  **enable**  to false. Otherwise, set it to true and give the correct image and tag so that the deployment will deploy database in k8s
    
6. For all other application configurations
    1. Update the  **image**  and  **tag**  to the one you want to deploy with else you might get "1 error(s): job failed: DeadlineExceeded"
    2. Update the  **resources**  if needed
    3. Update  **enable**  under  **xcApp**  to false if you do not want to deploy XC
    4. Set  **enable**  under  **fileBeat**  to false

**If you  search engine solar it will deploy aurora store if you select elastic it will deploy both solar and elastic**


**Share environment has the new search container and new tooling**

Run &quot; **helm install demo-qa-share ./ -n commerce –f my-values.yaml --set common.environmentType=share**&quot; to deploy the shared application, including tooling-web and search /data platform (future)

1. demo-qa-share is the helm release name. This name should be meaningful so it is easy to know what is deployed in this release. It is suggested to use tenant;env;envType; name convention
2. ./ is the path to the helm chart since you have already switched to the correct helm chart directory
3. -n commerce tells it to deploy it under commerce name space
4. -f my-values.yaml tells it to use additional value file
5. --set common.environmentType=share is to overwrite instance type to share so that the components/apps in this group (tooling-web) will be deployed

**Deploy live group**

helm install demo-qa-live ./ -f my-values.yaml -n commerce --set common.environmentType=live --set common.imagePullPolicy=Always

**Build Index**

**Create a connector**

  1. Access the ingest swagger API. Kindly update your domain in the below URL.
  [http://ingest.demoqa.mycompany.com/swagger-ui/index.html?url=/v3/api-docs&amp;validatorUrl=#/Create%20Connector%20Configuration/createConnector](http://ingest.demoqa.mycompany.com/swagger-ui/index.html?url=/v3/api-docs&amp;validatorUrl=#/Create%20Connector%20Configuration/createConnector)
  
 
  2. Try it out for POST /connectors, and download the below  "live reindex"  file for the Post body

   [live-reindex-connector.json](https://github02.hclpnp.com/commerce-dev/commerce-search-ingest/tree/master/Ingest/src/main/resources/deployments/commerce)

  1. Above call probably will hit 504 gateway timeout, ignore it as this call is taking long time to complete, but ingress timeout before it complete
  2. Monitor the connector creation in nifi UI ([http://nifi.demoqa.mycompany.com/nifi/](http://nifi.demoqa.mycompany.com/nifi/)), and when you see all reindex related process are created and no red square show up, it is ready to run them.


**Run connector**

  1. Access the ingest swagger API. Kindly update your domain in the below URL.
  [http://ingest.demoqa.mycompany.com/swagger-ui/index.html?url=/v3/api-docs&amp;validatorUrl=#/Index%20Data%20Operation/triggerIngest](http://ingest.demoqa.mycompany.com/swagger-ui/index.html?url=/v3/api-docs&amp;validatorUrl=#/Index%20Data%20Operation/triggerIngest)
  2. Try it out for POST /connectors/{id}/run, and put live.reindex in id .

 {
  "storeId" : "11", "envType" : "live"
}

Aurora store id =1 while emerald store id = 11

  3. Monitor the run in nifi UI ([http://nifi.demoqa.mycompany.com/nifi/](http://nifi.demoqa.mycompany.com/nifi/)). It will take long time to process. While it is running, you will see total queued data number changing.

 When above  numbers become 0/0, it is complete.
 
Try access the store to verify category and product are showing up

For Deployment Complete - Status should be running and in Ready state (all instances)
