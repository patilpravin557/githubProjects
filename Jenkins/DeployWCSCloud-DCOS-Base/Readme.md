# DeployWCSCloud-Base #


## Jenkins Job Usage ##
After populate environment related date to CMDB, you can launch this job to deploy a WCS cloud environment ( also for update environment )

<img src="http://9.111.213.154:8100/doc/images/DeployWCSCloud.png" width = "600" height = "350" alt="DeployWCSCloud" align=center /><br>

The backend logic is based on the input from Jenkins UI to generate DC/OS deploy template which will used to illustration how to deploy each container on DC/OS. then it
will all DC/OS API to trigger deployment on DC/OS and monitor the deployment status.

 - If you have deployed environment successfully, the filed LastDeployImages will show the image list in last deployment ( rely on Jenkins dynamic choice parameters ). you cloud copy them to re-use.
 - If you have a local db, you should set isDB2Container to false, then input the db's domain_name or IP.
 - You can also choose if the system to build index during the deployment of this environment. And if you are trying to deploy a live environment, the pipeline will do an index replica to search-repeater and search-slave.<br/>
 - IF you already defined the customize template, the backend scripts will merge the base template with them
 - IF deploy get success, it will store latest image list
Here is the snippet for the structure of deployHistory
```
               "deployHistory":[    //maintend when do the DeployWCCloude deploy
                       {
                           "version": "dfae-fadf-eadf-aebf-hhrf",
                           "images": {
                                  "ts-db": "ts-db:latest",
                                  "ts-app": "ts-app:latest",
                                  "ts-web": "ts-web:latest"
                            }
                       },
                       {
                           "version": "gjhu-uygt-dghb-dtyr-gdhg",
                           "images": {
                                  "ts-db": "ts-db: latest",
                                  "ts-app": "ts-app: latest",
                                  "ts-web": "ts-web: latest"
                            }
                       }
                    ]
```
For the data structure of third-party in remote configuration center Please see [MetaDataStructure](../MetaDataStructure.md)



## Jenkins Job Setup ##
You can create a pipeline item then edit this new item follow below steps

Note:
This Base job's owner is the jenkins admin, but when it be create as a new job for group, the group member can see it in dedicate view

================== Create DeployWCSCloud-Base Job ==============================<br>
Pipeline Name: DeployWCSCloud_Base <br>
Description: Deploy WCS Cloud Environment <br>

### Parameters ###
------------------ <br>
Name: group_id <br>
Type: String <br>
Default Vaule: <Empty> <br>
Description: The Group ID <br>

----------------- <br>
Name: envtype <br>
Type: Choices <br>
Default Value: auth / live / all <br>
Description: <br>

----------------- <br>
Name: LastDeployImages <br>
Type: Active Choices Reactive Reference Parameter <br>
Choice Type: Formatted HTML
Referenced parameters: group_id,environment_name,envtype
Script: Groovy Script
Script Content: commerce-devops-utilities/jenkins-pipeline/DeployWCSCloud-Base/groovy_script/LastDeployImages ( copy the content from this file )
Description: This parameter will show you the image list since you deployed the environment last time. This information is stored vault with build version after last deployment process. <br>

---------------- <br>
Name: images <br>
Default Value: <You Can Set Default Vaule As Below> <br>

```
"{'ts-db':'<docker repository>/ts-db:<tag>','ts-app':'<docker repository>/ts-app:<tag>','ts-web':'<docker repository>/ts-web:<tag>','search-app-master':'<docker repository>/search-app:<tag>','crs-app':'<docker repository>/crs-app:<tag>','search-app-repeater':'<docker repository>/search-app:<tag>','search-app-slave':'<docker repository>/search-app:<tag>','search-app-slave':'<docker repository>/search-app:<tag>''xc-app':'<docker repository>/xc-app:<tag>'}"
```

Note: you can replace Default Value for this job, above value just for reference, it may not work <br>

---------------- <br>
Name: environment_name  <br>
Type: String <br>
Default Value: <Empty> <br>
Description: The environment name, [production / non-production <id>] <br>

---------------- <br>
Name: isDBContainer <br>
Type: Choices  <br>
Default Value: True / False <br>

Node: IF you set this value to False, even though you specified the db docker, it will be ignore. This value should cooperation with your db hostname which stored in vault, because deploy scripts will fetch that vaule to set jdbc

---------------- <br>
Name: doBuildIndex <br>
Type: Choice <br>
Default Value: true / false <br>
Description: If creating this Group with build index <br>


### Pipeline ###
---------------- <br>
Definition: Pipeline Scripts
Script: <copy content from JenkinsFile>

<img src="http://9.111.213.154:8100/doc/images/DeployWCSCloud-pipeline.png" width = "600" height = "350" alt="DeployWCSCloud-pipeline" align=center /><br>

Note:
In JenkinsFile, we also defined some parameter which is same as you create through UI. IF you already create those parameter through UI, you can delete
related parameter in JenkinsFile content.


## Laydown Shell Scirpts On Gluster Cluster Server ##
1. Create folder /Glusterfs on one of Gluster cluster server
2. Copy glusterVolume.sh to /Glusterfs
3. Give glusterVolume.sh execute permission
