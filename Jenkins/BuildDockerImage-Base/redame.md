# BuildDockerImage-Base #

## Jenkins Job Usage ##
This pipeline is used to build customized docker image with your wcs customized code. You could build your own customized docker image for deploying customized WCS environment. All the customized code is stored nexus, and docker will build with this code into the OOB docker images. Then push these new docker images to docker registry.

THis Job suppose developer organize the customized package on nexus server based on group in release repository as below snapshot.  Each component's customization will be stored under path of related component

The backend scripts will based on this assumption based on input to fetch customization package

<img src="http://9.111.213.154:8100/doc/images/CustomizationCodeStructure.png" width = "600" height = "350" alt="CustomizationCodeStructure" align=center /><br>

<img src="http://9.111.213.154:8100/doc/images/BuildDockerImage_Base.png" width = "600" height = "350" alt="BuildDockerImage_Base" align=center /><br>

To build customized docker image, you need provide the base image tag, and the name of new image you want. The the build process will start on the docker-build jenkins slave node.

IF you want to change the source code structure and even not use nexus, you need to read the backend scripts and do some changes to match your requirement

When build finish backend scripts will based on your setting ( IF ForcePull_Image ) to decide if need to push the new build customized docker image
to docker repository which configured in your global variables in jenkins master.


## Setup Jenkins Job  ##
It is a jenkins base job which support user to build customized docker image, the owner should be the Jenkins admin. Group member just can see the new job which created based on it on Group dedicated view.


You can create a pipeline item then copy the scripts in JenkinsFile to pipeline script block
You also need to create Jenkins build parameter by manually

Here is the list for the build parameter for this Job:

PipelineName: BuildDockerImage_Base
Description: Use this job to build customized docker image

Use Case
1. IF group user just build immutable docker image for all environment, can leave the env_name empty
2. IF group user want to build a environment specified docker image under one group, they can fill ini the env_name,so the final docker image tag will have the env name in it
3. IF group user don't want to pull docker image each time to build customization docker image, they can choose ForcePull_Image to false to save time
4. IF group user don't want to push docker image to docker repository, they can choose ForcePush_Image to false

### Parameter ###
----------------------- <br>
Name: env_name  <br>
Type: String  <br>
Default Value: <Empty> <br>

IF you want to build environment specified docker image, you can input target environment name here
The final docker image tag will compose with <version>+<env_name>


----------------------- <br>
Name: group_id  <br>
Type: String  <br>
Default Value: <Empty> <br>


----------------------- <br>
Name: ForcePush_Image <br>
Type: Choice <br>
Default Value: False / True <br>
Description: Define if need pipeline to push image to docker registry ( Default: False ) <br>

-----------------------  <br>
Name: ForcePull_Image  <br>
Type: Choice  <br>
Default Vaule: False True  <br>
Description: Define if need pipeline to pull image from docker registry for each build ( Default: False ) <br>

-----------------------  <br>
Name: images_info  <br>
Default Vaule:  #here just a sample, you can replace it  <br>

{
    "name":"ts-app",   
     "base":"v22",
     "bundle": "1.1.2",
     "version": "v1"
},
{
     "name":"search-app",
     "base":"v14",
     "bundle": "1.1.2",
     "version": "v1"
},
{
     "name":"crs-app",
     "base":"v9",
     "bundle": "1.1.2",
     "version": "v1"
}

Descritpion:
Please provide images information you want to build
base    --> based OOB docker image tag
bundle  --> customized bundle version (it should work with the python scirpts to generate a full path of bundle)
version --> specify the new docker image tag, if empty, will use bundle version as tag for new docker image

Node, you can just leave the component you want to build and remove others. This sample just give you a full sample case 

For detailed logic about how to parse the images_info, please read docker-build-scripts/buildCusDocker.py

### Pipeline ###
---------------- <br>
Definition: Pipeline Scripts  <br>
Script: Copy content from JenkinsFile <br>

Note:
In JenkinsFile, we also defined some parameter which is same as you create through UI. IF you already create those parameter through UI, you can delete
related parameter in JenkinsFile content.
