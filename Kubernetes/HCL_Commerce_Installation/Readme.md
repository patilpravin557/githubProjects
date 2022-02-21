kubectl scale --replicas=4 deployment my-nginxdeployment 

********************** 

[root@com-kube-master ~]# viewLabels.sh demo qa live 

containerName=demoqaauthstore-web-9d4f8d9d9-mngdk 

containerName=demoqaauthts-app-f6df4df5b-4xf2s 

containerName=demoqaauthts-web-575885d5c6-pn7l9 

containerName=demoqaingest-app-7b6bdb859b-nlw7l 

9.1.4.0/search-ingest-app=v9-20201202-1223 

containerName=demoqalivequery-app-7b47976bbd-g94lg 

9.1.5.0/search-query-app=v9-20201214-1306 

containerName=demoqalivestore-web-844855c9f5-hbmbp 

9.1.4.0/store-web=v9-20201202-1047 

containerName=demoqalivets-app-5c6c66f7ff-4mkpw 

9.1.5.0/ts-app=v9-20201214-1147 

containerName=demoqalivets-web-5b4d8f6bf4-w4947 

9.1.4.0/ts-web=v9-20201202-2349 

containerName=demoqanifi-app-799548598d-j9hws 

9.1.4.0/search-nifi-app=v9-20201203-0425 

containerName=demoqaquery-app-6bc786cf49-b8znh 

9.1.4.0/search-query-app=v9-20201202-1132 

containerName=demoqaregistry-app-74ff945c7f-gbktb 

9.1.4.0/search-registry-app=v9-20201202-1845 

containerName=demoqatooling-web-77f9654bf5-vwj4x 

9.1.4.0/tooling-web=v9-20201202-0903 

containerName=hcl-cache-manager-app 

[root@com-kube-master ~]# 

********************************************************* 

 

 

************************************ 

helm delete my-vault -n vault  

helm delete demo-qa-auth 

helm delete demo-qa-live  

helm delete demo-qa-share  

*********************************** 

  

**************************Install vault*************************************** 

  

[root@com-kube-master HCL-Commerce-Helm-Charts-master]# pwd  

/root/commerce_helm/HCL-Commerce-Helm-Charts-master     

  

[root@com-kube-master HCL-Commerce-Helm-Charts-master]# helm install my-vault hcl-commerce-vaultconsul-helmchart/stable/hcl-commerce-vaultconsul/ -n vault -f hcl-commerce-vaultconsul-helmchart/stable/hcl-commerce-vaultconsul/my-values.yaml  

NAME: my-vault 

LAST DEPLOYED: Wed Jul  8 15:38:47 2020   

NAMESPACE: vault   

STATUS: deployed   

REVISION: 1   

NOTES:   

Chart: hcl-commerce-vaultconsul-2.0.0   

This vault-Consul deployment is for development only.   

Please check Vault-Consul helm release status in 1 min. 

  

  

[root@com-kube-master HCL-Commerce-Helm-Charts-master]# kubectl get po -n vault  

NAME                            READY   STATUS      RESTARTS   AGE   

  

my-vault-health-test            0/1     Completed   0          14d   

  

vault-consul-7bcff65787-rllwc   2/2     Running     0          34s   

*******************************************************************   

  

*******************************Install share ********************************* 

  

[root@com-kube-master hcl-commerce]# helm install demo-qa-share . -f my-values.yaml --set common.environmentType=share -n commerce  

NAME: demo-qa-share   

LAST DEPLOYED: Wed Jul  8 15:44:12 2020   

NAMESPACE: commerce   

STATUS: deployed  

REVISION: 1   

NOTES:   

Chart: hcl-commerce-2.0.0  

HCL Commerce V9 shared components (new tooling and data platform) have been deployed, and it will take several minutes to fully start. 

If you haven't deployed the HCL Commerce auth or live, you can deploy it now.   

helm install demo-qa-auth <path-to-helmchart> -f <custom-values-yaml-file> -n <namespace>  

helm install demo-qa-live <path-to-helmchart> -f <custom-values-yaml-file> -n <namespace>   

  

[root@com-kube-master hcl-commerce]# kcgp 

NAME                                           READY   STATUS      RESTARTS   AGE   

demoqaingest-app-646f6b78cb-nwzkn              1/1     Running     0          99s  

demoqanifi-app-74fd57ff89-rrjv2                1/1     Running     0          99s  

demoqaquery-app-5d44657ffc-2b8v7               1/1     Running     0          99s 

demoqaregistry-app-59c46cff69-6t9pl            1/1     Running     0          100s  

demoqatooling-web-6874dbff8-98kmz              1/1     Running     0          100s  

  

************************************************************************************************** 

  

*****************************Install demo-qa auth ************************************************ 

  

[root@com-kube-master hcl-commerce]# helm install demo-qa-auth . -f my-values.yaml --set common.environmentType=auth -n commerce  

NAME: demo-qa-auth  

LAST DEPLOYED: Wed Jul  8 15:47:24 2020   

NAMESPACE: commerce   

STATUS: deployed   

REVISION: 1   

NOTES:   

Chart: hcl-commerce-2.0.0   

HCL Commerce V9 demo-qa-auth release startup will take average 10-15 minutes with sequence. 

Access Environment:   

1. Check ingress server IP address.  

kubectl get ingress -n <Namespace>  

2. Create the ingress server IP and hostname mapping on your server by editing the  /etc/hosts file.  

<Ingress_IP> tsapp.demoqaauth.nonprod.hclpnp.com   

<Ingress_IP> cmc.demoqaauth.nonprod.hclpnp.com   

<Ingress_IP> accelerator.demoqaauth.nonprod.hclpnp.com  

<Ingress_IP> admin.demoqaauth.nonprod.hclpnp.com   

<Ingress_IP> org.demoqaauth.nonprod.hclpnp.com  

<Ingress_IP> www.demoqaauth.nonprod.hclpnp.com   

<Ingress_IP> search.demoqaauth.nonprod.hclpnp.com  

3. Access the environment with following URLs:   

React Store Front:   

https://www.demoqaauth.nonprod.hclpnp.com/   

Management Center:   

https://cmc.demoqaauth.nonprod.hclpnp.com/lobtools/cmc/ManagementCenter   

Organization Admin Console:   

https://org.demoqaauth.nonprod.hclpnp.com/webapp/wcs/orgadmin/servlet/ToolsLogon?XMLFile=buyerconsole.BuyAdminConsoleLogon   

Accelerator:   

https://accelerator.demoqaauth.nonprod.hclpnp.com/webapp/wcs/tools/servlet/ToolsLogon?XMLFile=common.mcLogon   

Commerce Admin Console:  

https://admin.demoqaauth.nonprod.hclpnp.com/webapp/wcs/admin/servlet/ToolsLogon?XMLFile=adminconsole.AdminConsoleLogon   

This takes several minutes during which time you may want to tail the logs of the ts-app container to view startup status:  

  

[root@com-kube-master hcl-commerce]# kcgp  

NAME                                           READY   STATUS      RESTARTS   AGE  

demoqaauthquery-app-749cc47685-7qqx5           1/1     Running     0          14m  

demoqaauthstore-web-6bf9ff9597-p768b           1/1     Running     0          14m  

demoqaauthts-app-6c6dc9bcb5-t5z9h              1/1     Running     0          14m  

demoqaauthts-web-566b5bcfdf-gjngx              1/1     Running     0          14m   

*********************************************************************************************************** 

  

**************************************Install  demoqa live****************************************************** 

  

[root@com-kube-master hcl-commerce]# helm install demo-qa-live . -f my-values.yaml --set common.environmentType=live -n commerce  

NAME: demo-qa-live   

LAST DEPLOYED: Wed Jul  8 16:03:00 2020   

NAMESPACE: commerce   

STATUS: deployed   

REVISION: 1   

NOTES:   

Chart: hcl-commerce-2.0.0   

HCL Commerce V9 demo-qa-live release startup will take average 10-15 minutes with sequence.  

Access Environment:  

1. Check ingress server IP address.   

kubectl get ingress -n <Namespace>  

2. Create the ingress server IP and hostname mapping on your server by editing the  /etc/hosts file.  

<Ingress_IP> tsapp.demoqalive.nonprod.hclpnp.com   

<Ingress_IP> cmc.demoqalive.nonprod.hclpnp.com  

<Ingress_IP> accelerator.demoqalive.nonprod.hclpnp.com  

<Ingress_IP> admin.demoqalive.nonprod.hclpnp.com  

<Ingress_IP> org.demoqalive.nonprod.hclpnp.com   

<Ingress_IP> www.demoqalive.nonprod.hclpnp.com  

<Ingress_IP> search.demoqalive.nonprod.hclpnp.com   

3. Access the environment with following URLs:  

React Store Front:   

https://www.demoqalive.nonprod.hclpnp.com/   

Management Center:   

https://cmc.demoqalive.nonprod.hclpnp.com/lobtools/cmc/ManagementCenter   

Organization Admin Console:   

https://org.demoqalive.nonprod.hclpnp.com/webapp/wcs/orgadmin/servlet/ToolsLogon?XMLFile=buyerconsole.BuyAdminConsoleLogon  

Accelerator:   

https://accelerator.demoqalive.nonprod.hclpnp.com/webapp/wcs/tools/servlet/ToolsLogon?XMLFile=common.mcLogon   

Commerce Admin Console:   

https://admin.demoqalive.nonprod.hclpnp.com/webapp/wcs/admin/servlet/ToolsLogon?XMLFile=adminconsole.AdminConsoleLogon  

  

[root@com-kube-master hcl-commerce]# kcgp  

NAME                                           READY   STATUS      RESTARTS   AGE  

demoqalivequery-app-f5bdf4dcb-xzpvr            0/1     Init:0/1    0          47s 

demoqalivestore-web-57d4f84b8f-9hg58           0/1     Running     0          47s  

demoqalivets-app-5578fd8666-wd6fp              0/1     Running     0          47s 

demoqalivets-web-75c968b4bf-nx7xs              0/1     Init:0/1    0          47s    

****************************************************************************************************************** 
