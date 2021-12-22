**Install Vault**

1. Create a namespace vault
  - kubectl create ns vault
  
2. Create a namespace commerce
  - kubectl create ns commerce
3. Vault helm chart is at below loaction
   [https://github02.hclpnp.com/commerce-dev/commerce-helmchart](https://github02.hclpnp.com/commerce-dev/commerce-helmchart)
   
4. Move to folder 
    cd /root/commerce-helmchart-master/hcl-commerce-vaultconsul-helmchart/stable/hcl-commerce-vaultconsul/

5. Edit values.yaml file

Select Domain name of your choice.
   
   --ExternalDomain : .nidhiscompany.com

  --Change the tenant if you want to name it differently. Note, if you change the tenant name here, you will also need to change the  tenant in commerce helm chart values to match the same name. 

  --By default it does not create ingress for vault service. If you want to create an ingress to access vault ui,
    set enableIngress to true 
  
  --As part of the vault deployment, it will create a vault token secret in the 'commerce' namespace, so that the commerce application can get the vault token from that secret. If you plan to deploy commerce in other name spaces, you need to create those names spaces now (kubectl create ns <namespace>), and list all of the namespaces in commerceNameSpaces.
  
  E.g if I want to deploy 2 commerce environments 'dev' and 'qa' in 'commerce-dev' and 'commerce-qa' name spaces. You would need to do: 

    kubectl create ns commerce-dev 

    kubectl create ns commerce-qa 

    kubectl delete ns commerce  

Config commerceNameSpaces to following: 

commerceNameSpaces:  

    - commerce-dev 

    - commerce-qa 
    
**Under vaultConsul:** 

  -Update  consulImageTag and vaultImageTag if you want to test different images 

  -Update vaultToken to your own value if you don't want to use the default one 

  -If you change the vaultToken value, you will need to run "echo -n '<token>' | base64" and update vaultTokenBase64 with this value 

  - Update the data under vaultData. E.g update the db information
  
  **Under QA: 
          Live DB**
   - Update the toolingBaseUrl with your Domain URL
   
   toolingBaseUrl: "https://cmc.demoqalive.nidhiscompany.com/tooling"
   
6. Deploy vault using this command:

- helm install my-vault commerce-helmchart-master/hcl-commerce-vaultconsul-helmchart/stable/hcl-commerce-vaultconsul -n vault -f commerce-helmchart-master/hcl-commerce-vaultconsul-helmchart/stable/hcl-commerce-vaultconsul/values.yaml

  my-vault is the helm release name 
  
  hcl-commerce-vaultconsul-helmchart/stable/hcl-commerce-vaultconsul/ is the helm chart path 
  
  -n vault tells it to deploy it under vault namespace 
  
  -f hcl-commerce-vaultconsul-helmchart/stable/hcl-commerce-vaultconsul/my-values.yaml tells it to use my-values.yaml file to render the template.
  
  
7. Run kubectl get pod -n vault  to make sure vault-consul-xxxx has 2/2 in READY column

8. Optionally you can run helm test my-vault -n vault; to run test
 
       $ helm test my-vault -n vault 
       Pod my-vault-health-test pending 
       Pod my-vault-health-test pending 
       Pod my-vault-health-test pending 
       Pod my-vault-health-test succeeded 
       NAME: my-vault
       LAST DEPLOYED: Wed Mar 25 15:03:22 2020 
       NAMESPACE: vault 
       STATUS: deployed 
       REVISION: 1 
       TEST SUITE: my-vault-health-test 
       Last Started:   Wed Mar 25 15:07:19 2020 
       Last Completed: Wed Mar 25 15:07:39 2020 
       Phase:  Succeeded 
       NOTES: Chart: hcl-commerce-vaultconsul-2.0.0   
       This vault-Consul deployment is for development only.   
       Please check Vault-Consul helm release status in 1 min.

9. Finally list the secret in your commerce namespace to make sure the secret has been created.

        $ kubectl get secret vault-token-secret -n commerce 
  
        NAME TYPE     DATA   AGE vault-token-secret   Opaque   1      7m44s
