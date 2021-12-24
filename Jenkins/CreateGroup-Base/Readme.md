# CreateGroup-Base #

## Jenkins Job Usage ##

<img src="http://9.111.213.154:8100/doc/images/CreateGroupJob.png" width = "600" height = "350" alt="CreateGroup_Base" align=center /><br>


This pipeline is help user create a new group. Group is most like the "Tenant", we use
it to group the environment and environment configuration on Vault for different user.

This Job should be controlled by IT Admin.

It contains two stages below, when IT Admin trigger this Job by input new Group name, it will finish below job by sequence. IF Group
exist, you can ignore this Job and jump to next "PrepareEnv" job.

1.Create a vault mount path. <br>
   - It will be the root path to store any environment's configuration under it like as key-value tree.
   - The group name will be the root path, Environment name will be the second path and Environment config are both under second path.

2.Create a jenkins group and create all the base jobs to this new group. <br>
   - It will create a special Jenkins View for this new Group
   - It will copy based job to New Group view and rename them


After creating group, a new view of jenkins will be created. IT Admin can setup role permission and assign access permission
just for the member of new group. So when group member login Jenkins, they just can see the jenkins job belongs to their group.

<img src="http://9.111.213.154:8100/doc/images/JenkinsJobBase.png" width = "600" height = "350" alt="JenkinsJobBase_View" align=center /><br>


## Jenkins Job Setup ##
You can create a pipeline item then copy the scripts in JenkinsFile to pipeline script block. You also need to 
create below project parameter by manually.

Pipeline Name:  CreateGroup_Base

Description:
This script is to initialize Vault and create namespace per tenant.

### Parameters ###
--------------------
Name: group_id
Default Value: <Empty>
Description: The group's unique identifier

### Pipeline ###
---------------- <br>
Definition: Pipeline Scripts <br>
Script: Copy content from JenkinsFile<br>

Note:
In JenkinsFile, we also defined some parameter which is same as you create through UI. IF you already create those parameter through UI, you can delete
related parameter in JenkinsFile content.


## Job Dependence ##
For running this job you need to make sure in Jenkins configuration,
you have set the global parameter "jenkins_server" with format http://jenkins-server-ip:port
