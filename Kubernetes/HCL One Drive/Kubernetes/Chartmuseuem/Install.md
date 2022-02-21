Helm Chart Repository hosting options 

1. google compute cloud bucket 

2. AWS S3 bucket 

3. Github pages 

4. webserver (chartmuseum) 

Chartmuseum Installation Steps 

Create dir - chartmuseum 

Download Chartmuseum(https://chartmuseum.com/docs/#installation) 

     curl -LO https://s3.amazonaws.com/chartmuseum/release/latest/bin/linux/amd64/chartmuseum 

Give the execute permission                  

                chmod +x ./chartmuseum 

                 mv ./chartmuseum /usr/local/bin 

Install chartMuseum-webserver  

[root@comlnx91 ~]# chartmuseum --debug --port=8080 --storage="local" --storage-local-rootdir="./chartstorage"  

  

Add Chartmuseum Repository Steps 

Create Repo 

helm repo add mychartmuseumrepo http://10.190.67.115:8080 

List Repo – 
 
helm repo list 
 
NAME                                  URL 
 
mychartmuseumrepo       http://10.190.67.115:8080 

  

Add Chart To Repo Using Curl (Mathod 1) 

Go to chart directory 

Update Chart.yaml file with description and version which is used to maintain the version 

Create a package of chart directory 
 
helm package mychart/ 

Package will be created 
 
[root@comlnx91 helm_demo]# ls 
 
mychart  mychart-0.1.0.tgz   

Add package to the repo  
 
curl --data-binary "@mychart-0.1.0.tgz" http://10.190.67.115:8080/api/charts 
 
  

  

Add Chart To Repo Using helm-push plugin (Mathod 2) 

Install helm plugin 

    helm plugin install https://github.com/chartmuseum/helm-push.git 

Downloading and installing helm-push v0.8.1 ... 

https://github.com/chartmuseum/helm-push/releases/download/v0.8.1/helm-push_0.8.1_linux_amd64.tar.gz 

Installed plugin: push 

  

Push the package to repo 
 
[root@comlnx91 helm_demo]# helm push helmpushdemo/ mychartmuseumrepo 
 
Pushing helmpushdemo-0.1.0.tgz to mychartmuseumrepo... 

Done. 

Update Repo 

Run update command to reflect the newly created chart 

helm repo update 

Check charts inside Repo 

Verify chart has been available inside repo 

[root@comlnx91 helm_demo]# helm search repo mychartmuseumrepo 

NAME                                                      CHART VERSION   APP VERSION     DESCRIPTION 

mychartmuseumrepo/helmpushdemo  0.1.0                     1.16.0           Helm Push Plugin Demo 

mychartmuseumrepo/mychart               0.1.1                      1.16.0          Repo Demo in Helm ….. 

Maintain Chart Version 

Update chart version into chart.yaml 

Create package 

Add new package to the repo 

Verify the newly added charts 
 
[root@comlnx91 chartstorage]# helm search repo -l mychartmuseumrepo 
 
NAME                            CHART VERSION   APP VERSION     DESCRIPTION 
 
mychartmuseumrepo/mychart       0.1.1           1.16.0          Repo Demo in Helm using Chartmuseum updated fro... 

mychartmuseumrepo/mychart       0.1.0           1.16.0          Repo Demo in Helm usinfgChartmuseum 

       

  

  

  

Step To Install Helm chart directly from Chartmuseusm repository  

Search for the chart 

 [root@comlnx91 helm_demo]# helm search repo mychartmuseumrepo 

NAME                                      CHART VERSION   APP VERSION     DESCRIPTION 

mychartmuseumrepo/mychart       0.1.1              1.16.0          Repo Demo in Helm using…  

  

Install chart by giving the name 
 
helm install db2exporter-helmchart mychartmuseumrepo/mychart 
 
 
 
NAME: db2exporter-helmchart 
 
LAST DEPLOYED: Wed Jun 24 05:06:58 2020 
 
NAMESPACE: commerce 
 
STATUS: deployed 
 
REVISION: 1 
 
TEST SUITE: None 

List the deployed charts 
 
[root@comlnx91 chartstorage]# helm ls 
 
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION 
 
db2exporter-helmchart   commerce        1               2020-06-24 05:06:58.8213705 -0400 EDT   deployed        mychart-0.1.1           1.16.0 
