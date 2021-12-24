# This jenkins file used to support user to create Dockerfile on Kubernetes #

Dockerfile content will be stored in config map

* You can sepcify namespace where this config map will be generated ( default namespace will be used if not specify )
* You can sepcify component for Dockerfile, the config map will be named as <Tenat><Env>-<Component>-dockerfile, otherwise, it will be named as <Tenant><Env>-dockerfile


In this JenkinsJob

dependence on the jenkins plugin [Active+Choices+Plugin](https://wiki.jenkins.io/display/JENKINS/Active+Choices+Plugin)

You need to install those plugins although:
```
    [scriptler plugin] https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/scriptler/2.9/
    [uno-choice plugin] https://repo.jenkins-ci.org/releases/org/biouno/uno-choice
```


# Additioanl Filed #
```
Type: Active Choices Reactive Reference Parameter
Name: Current_Dockerfile
Groovy Scripts:
if(Component == ''){
    dockerConfigMapName="dockerfile"
}else{
    dockerConfigMapName=Component+"-dockerfile"
}
def process = ["python","/commerce-devops-utilities/kube-python/kubcli.py","fetchconfmap","-tenant",group_id,"-env",environment_name,"-name",dockerConfigMapName,"-namespace",namespace].execute()
result=process.in.text
return "<textarea name='dockerfile' style='width:700px;height:400px;'> ${result}</textarea>"

Choice Type: FORMATED_HTML
Referenced Parameter: Tenant,EnvName,Component,NameSpace
```
