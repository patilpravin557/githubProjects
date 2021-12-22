# How to install Commerce in GKE using nginx
First create a cluster that can support your deployment, there are several cluster types that you can create refer to the [GKE How-to for detailed information](https://cloud.google.com/kubernetes-engine/docs/how-to). Specific compute-engine requirements are not given as each deployment has its particular setup.
For demo/test purposes you can use a cluster of:
   * size: 4 nodes
   * compute engine type: e2-standard-8 (8 vCPU, 32Gb Mem)

## Setup your gcloud environment
[!images/setup_gcloud_1.png]
1. gcloud container clusters get-credentials av-cluster --zone <ZONE> --project <PROJECT_NAME>

# Download all the required packages from Flexnet:
- HCL Commerce Helm Charts
- All HCL Commerce container images


## Install the external components
### Install Vault
Following the steps on from the Help Center: ["Deploying a development Vault for HCL Commerce on Kubernetes"](https://help.hcltechsw.com/commerce/9.1.0/install/tasks/tdeploykubern91-vault.html)
1. `kubectl create ns vault`
1. `kubectl create ns commerce`
1. In the bundle for the HELM Charts, navigate to: `cd hcl-commerce-vaultconsul-helmchart/stable/hcl-commerce-vaultconsul`
1. open and modify the files on `vault.yaml`
   1. the important parts to change are:
      1. vaultToken
      1. vaultToken64
      1. vaultData: this should contain a map for all your secrets as defined in the file.
1. `helm install vault ./ -n vault -f values.yaml`
1. Ensure that container is running: `helm install vault ./ -n vault -f values.yaml`

### Create PersistentVolumeClaim for ElasticSearch and Nifi
Create two PersistentVolumeClaims in GCP.

| Name | Namespace|
|---|---|
| demo-qa-nifi-pvc | commerce |
| elasticsearch-master-elasticsearch-master-0 | elastic |

1.Using [elastic-pvc.yaml](./elastic-pvc.yaml)
1. `kubectl create -f elastic-pvc.yaml`
1. Using [nifi-pvc.yaml](./nifi-pvc.yaml)
1. `kubectl create -f nifi-pvc.yaml`
1. `kubectl get pvc --all-namespaces`

### Install Elasticsearch
Following the steps on frrom the Help Center: ["Deploying Elasticsearch"](https://help.hcltechsw.com/commerce/9.1.0/install/tasks/tdeploykubern91-commerce.html)
1. `kubectl create ns elastic`
1. `helm repo add elastic https://helm.elastic.co`
1. `helm repo update`
1. In the bundle for the HELM Charts, navigate to: `hcl-commerce-helmchart/sample_values/elasticsearch-values.yaml`, is a sample file to use for your Elastisearch deployment
1. `helm install elasticsearch elastic/elasticsearch -n elastic -f elasticsearch-values.yaml`
1. Ensure that container is running: `kubectl get pods -n elastic`

### Install Zookeeper
Following the steps on from the Help Center: ["Deploying Zookeeper"](https://help.hcltechsw.com/commerce/9.1.0/install/tasks/tdeploykubern91-commerce.html)
1. `kubectl create ns zookeper`
1. `helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator`
1. `helm repo update`
1. In the bundle for the HELM Charts, navigate to: `hcl-commerce-helmchart/sample_values/zookeeper-values.yaml`, is a sample file to use for your Zookeeper deployment
1. `helm install zookeeper -n zookeeper incubator/zookeeper -f zookeeper-values.yaml`
1. Ensure that container is running: `kubectl get pods -n zookeeper`


## Testing Elasticsearch using curlalpine
To test elasticsearch within the cluster first we need to deploy a curlalpine container
1. using [curl.yaml](./curl.yaml)
1. `kubectl apply -f curl.yaml`
1. To find out the elasticsearch-master IP inside of the cluster `kubectl get svc --all-namespaces`
1. To find out the name of the ***curlAlpine*** pod: `kubectl get pods`
1. `kubectl exec -it <_curlAlpine_> sh`
1. `curl http://<_CLUSTER-elasticsearch-master:9200/_cluster/state?pretty`


## Prepare the cluster for Commerce

### Setup the roles
:IMPORTANT: To apply RBAC in your GCP cluster you need to work with your GCP administrator and [Enable RBAC in GCP](https://cloud.google.com/kubernetes-engine/docs/how-to/role-based-access-control)

1. On the Web console using IAM tools, enable your user to have the role: `Kubernetes Engine Admin`

1. In the computer that has kubectl tools installed, use: `kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user <_user-account_>`

Only after you have read and understand the GCP clusterrolebinding then proceed with the following steps.

1. Download [clusterrole.yaml](clusterrole.yaml)

1. `kubectl create -f clusterrole.yaml`


### Create RBAC policies

1. Using the rbac.yaml that comes with the helm charts,

1. In the rbac.ymal modify the `<namespace>` to match `commerce`, like [rbac.yaml](../rbac.yaml)

1. `kubectl create -f rbac.yaml`



## Load and Push all the images to your private GCP repository
This involves using some kubectl commands and finding out the URL of your registry, lets assume that the docker registry is: https://sample.gcr.io/my-project, and that all container images have been downloaded. We only show the process for one, but is the same process for all container images.

1. download the images from Flexnet [https://hclsoftware.flexnetoperations.com/flexnet/operationsportal/entitledDownloadFile.action?downloadPkgId=HCL_Commerce_Enterprise_Version_9.1.1.0&fromRecentPkg=true](https://hclsoftware.flexnetoperations.com/flexnet/operationsportal/entitledDownloadFile.action?downloadPkgId=HCL_Commerce_Enterprise_Version_9.1.1.0&fromRecentPkg=true)
1. `docker load -i /Users/angelvera/Downloads/HCL_Commerce_Enterprise_9.1.1.0_Gem_Store_Web_Server_x86-64.tgz` to load an image in your local docker repository
1. `docker tag commerce/store-web:9.1.1.0 sample.gcr.io/my-project/commerce/store-web:9.1.1.0` to tag the images for uploading them into your remote docker registry
1. `docker push sample.gcr.io/my-project/commerce/store-web:9.1.1.0` to upload the image into the remote docker registry
1. ***repeat the process for all the HCL Commerce images***

## Install nginx
1. `helm repo add nginx https://helm.nginx.com/stable`
1. `helm repo update`
1. `kubectl create ns nginx`
1. `helm install ngingx-ingress stable/nginx-ingress -n nginx`
1. `kubectl --namespace nginx get services -o wide -w nginx-ingress-controller`, to see the external IP



## Use Helm to install Commerce shared components
1. `helm install demo-qa-share ./ -n commerce --set common.environmentType=share`
   1. If you run into problems use:
      1. `kubectl get jobs -n commerce`
      1. `kubectl describe jobs -n commerce <_JOB_NAME_STARTING_WITH_WCS_>`
      1. `helm uninstall demo-qa-sharer -n commerce` to clear up the install
      1. `kubectl delete jobs -n commerce <_JOB_NAME_STARTING_WITH_WCS_>`, to clear up all the jobs before next run

## Use Helm to install Commerce Auth components
1. `helm install demo-qa-auth ./ -n commerce --set common.environmentType=auth`

```

NAME: demo-qa-auth
LAST DEPLOYED: Wed Sep 23 15:59:16 2020
NAMESPACE: commerce
STATUS: deployed
REVISION: 1
NOTES:
Chart: hcl-commerce-2.0.1
HCL Commerce V9 demo-qa-auth release startup will take average 10-15 minutes with sequence.

Access Environment:

1. Check ingress server IP address.
kubectl get ingress -n <Namespace>


2. Create the ingress server IP and hostname mapping on your server by editing the  /etc/hosts file.

<Ingress_IP> tsapp.demoqaauth.devavcommerce.com
<Ingress_IP> cmc.demoqaauth.devavcommerce.com
<Ingress_IP> accelerator.demoqaauth.devavcommerce.com
<Ingress_IP> admin.demoqaauth.devavcommerce.com
<Ingress_IP> org.demoqaauth.devavcommerce.com
<Ingress_IP> store.demoqaauth.devavcommerce.com
<Ingress_IP> www.demoqaauth.devavcommerce.com
<Ingress_IP> search.demoqaauth.devavcommerce.com

3. Access the environment with following URLs:
Aurora Store Front:
https://store.demoqaauth.devavcommerce.com/wcs/shop/en/auroraesite

React Store Front:
https://www.demoqaauth.devavcommerce.com/

Management Center:
https://cmc.demoqaauth.devavcommerce.com/lobtools/cmc/ManagementCenter

Organization Admin Console:
https://org.demoqaauth.devavcommerce.com/webapp/wcs/orgadmin/servlet/ToolsLogon?XMLFile=buyerconsole.BuyAdminConsoleLogon

Accelerator:
https://accelerator.demoqaauth.devavcommerce.com/webapp/wcs/tools/servlet/ToolsLogon?XMLFile=common.mcLogon

Commerce Admin Console:
https://admin.demoqaauth.devavcommerce.com/webapp/wcs/admin/servlet/ToolsLogon?XMLFile=adminconsole.AdminConsoleLogon

```

# Installation is now complete
Your auth environments should now be up and running, if you run into problems. At this point commerce is successfully installed and you can access the following URLs... But before you go and try them out..  no index has build so you will not be able to successfully navigate the site. To build the index follow: [#To build the HCL Commerce Search when using Elasticsearch]
* https://www.demoqaauth.devavcommerce.com/Emerald
* https://store.demoqaauth.devavcommerce.com/wcs/shop/en/auroraesite




# To build the HCL Commerce Search when using Elasticsearch
https://help.hcltechsw.com/commerce/9.1.0/install/tasks/tig_install_v91search.html?hl=building%2Cindex

Index Using the curlAlpine container
1. `kubectl get svc -n commerce` to get the name of the ts-app services
1. `kubectl exec -it curlalpine-7d69c97c9f-s5pjp sh`
1. `curl -k -s -X POST -u spiuser:passw0rd 'https://demoqaauthts-app.commerce.svc.cluster.local:5443/wcs/resources/admin/index/dataImport/build?connectorId=auth.reindex&storeId=1'`

## To get the status of the build inde job
1. `kubectl exec -it curlalpine-7d69c97c9f-s5pjp sh`
1. `curl -k -s -X GET -u spiuser:passw0rd 'https://demoqaauthts-app.commerce.svc.cluster.local:5443/wcs/resources/admin/index/dataImport/status?jobStatusId=1001'`
1. When the jobs returns `-1` it is still running, when the job completes it should return a `0`, all other cases refer to the help center.


```
{"status":{"finishTime":"2020-09-25 19:54:25.787389","lastUpdate":"2020-09-25 19:54:25.787389","progress":"100%","jobStatusId":"1001","startTime":"2020-09-25 19:48:06.13224","message":"Ingest job finished successfully for storeId: 1.\n","jobType":"SearchIndex","properties":"[storeId=1, connectorId=auth.reindex]","status":"0"}}
```




## Cleaning process!
If at any point in time you need cleanup your cluster due to a bad install. It is recommended that you review and delete appropriate storages, in the case of K8S all PV and PVC associated with zookeper, nifi, and elastic search.
   :information: *** note that if during one of this delete actions, your terminal seems to hang, using another terminal check that all pods related to elastic search, nifi or zookeper are not existing anymore. If a pod is still exist (even during the terminating status) that uses the pv, or pvc, kubernetes will not let you delete the persisent storage ***
1. `kubectl get pv,pvc --all-namespaces`
1. `kubectl delete pvc -n commerce --all`
1. `kubectl delete pvc -n elastic --all`
1. `kubectl delete pvc -n zookeeper --all`
1. `kubectl delete pv -n commerce --all`
1. `kubectl delete pv -n elastic --all`


## Links

# FAQ / Debug
[Install_FAQ.md](install_FAQ.md)
