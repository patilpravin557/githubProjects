# PrepareEnv-Base #


## Jenkins Job Usage ##
After new Group be create, member of group can logon Jenkins, to create dedicated environment node path on Vault and populate all environment related parameters to vault. When deploy V9 by passing Vault Info and Group/Environment/EnvType
as Docker's environment variable, Docker startup scripts will generate Vault path with those variable and find related data to do the configuration inside of Docker.

<img src="http://9.111.213.154:8100/doc/images/PrepareEnv_Base.png" width = "600" height = "350" alt="PrepareEnv_Base" align=center /><br>

IF this is a new environment, Jenkins job will help to create the related sub-path and update value.
Some value can be empty, if you don't know how to field.

IF this is a exist environment, Jenkins job will update existed environment configuration.

This job compose with below stags:

1. Pop base parameters.

2. Generate the db password encrypted including merchant_key, session_key, db_password, dba_password, then write them to vault. ( need the jenkins-slave-utility install docker and can download commerce utility docker image)

   This stage will take the process encrypted within a docker container of ts-utility. The procedure of all the stage is:
   get necessary parameters (session_key, merchant_key, db_password, dba_password) -> start a docker container with the image: ts-util -> encrypt all the keys and output -> save into the vault and consul.
   The data structure in vault, see: [MetaDataStructure.md](../MetaDataStructure.md)

3. Pop vault OIDC

All three stages point to related backend scripts. You can find the scripts path in JenkinsFile for this pipeline.

Customer can extend this job to add more filed to populated more data to Vault, of course, the backend scripts need to made change as well.  <br />


## Jenkins Job Setup ##
data ( this also need change python scripts )

You can create a new "pipeline" item and copy content in Jenkinsfile to pipeline. After that you also need to create below project parameters:<br />

### Parameters ###

----------------<br />
Name: group_id<br />
Type: String<br />
Default Value: <Empty><br />
Description: The group's unique identifier<br />

----------------<br />
Name: environment_name<br />
Type: String<br />
Default Value: <Empty><br />
Description: The environment name, e.g product, qa, dev, etc.<br />

----------------<br />
Name: instance_type<br />
Type: Choice<br />
Default Value: live / auth<br />
Description: The transaction server instance type , choices=["live", "auth"]<br />

----------------<br />
Name: db_hostname<br />
Type: String<br />
Default Value: <tenant><env><envtyp>db.marathon.l4lb.thisdcos.directory<br />
Description: The DB host name<br />

----------------<br />
Name: db_port<br />
Type: String<br />
Default Value: 50000<br />
Description: The DB port number<br />

----------------<br />
Name: db_name<br />
Type: String<br />
Default Value: mall<br />
Description: The DB name<br />

----------------<br />
Name: db_user<br />
Type: String<br />
Default Value: wcs<br />
Description: The db user name<br />

----------------<br />
Name: db_password<br />
Type: String<br />
Default Value: wcs1<br />
Description: The db password<br />

----------------<br />
Name: dba_user<br />
Type: String<br />
Default Value: wcs<br />
Description: The dba user name<br />

----------------<br />
Name: dba_password<br />
Type: String<br />
Default Value: wcs1<br />
Description: The dba password<br />

----------------<br />
Name: domain_name<br />
Type: String<br />
Default Value: marathon.l4lb.thisdcos.directory<br />

----------------<br />
Name: merchant_key<br />
Type: String<br />
Default Value: 1a1a1a1a1a1a2b2b2b2b2b2b<br />

----------------<br />
Name: imageRepo<br />
Type: String<br />
Default Value: bxv8v141.cn.ibm.com/commerce<br />

----------------<br />
Name: oidcClientId<br />
Type: String<br />
Default Value: <br />

----------------<br />
Name: oidcClientSecret<br />
Type: String<br />
Default Value: <br />

----------------<br />
Name: blueIDServer<br />
Type: String<br />
Default Value: <br />

----------------<br />
Name: blueIDProviderHost<br />
Type: String<br />
Default Value: <br />

----------------<br />
Name: isTsDb<br />
Type: choice <br />
Default Value: True & False<br />

### Pipeline ###
---------------- <br>
Definition: Pipeline Scripts  <br>
Script: Copy content from JenkinsFile <br>



Note:
1. In JenkinsFile, we also defined some parameter which is same as you create through UI. IF you already create those parameter through UI, you can delete
related parameter in JenkinsFile content.

2. For encrypt merchantkey, you need input a key for merchantkey to encrypt. The you can find default key
in /opt/WebSphere/CommerceServer90/ts.ear/xml/config/KeyEncryptionKey.xml in utility docker. When you prepare this Jenkins job, please replace the value of "keyForMerchantkey" in commerce-devops-utilitis/vault-utilities/popVaultEnvEncrypt.py

3. IF you already changed the key for merchantkey, please use the one you changed. to replace value of "keyForMerchantkey" in commerce-devops-utilitis/vault-utilities/popVaultEnvEncrypt.py


# TODO #

In latest docker image, we support to auto config trace level in CD pipeline. That means, you don't need to rebuild docker image to change the trace level.  The trace level already is a environment related variable stored on Vault

As default the related value is empty, so the trace level will use default one when build OOB docker, IF you want to change the trace level, please do as below ( so far, we don't have jenkins job to do that )

Run below command on your server to populate the trace level to vault:

curl -X POST -H "X-Vault-Token:26d57e48-622b-2fc1-d4b5-e88181914f86" -d '{"value":"*=info:enable.trace.log.*=all:com.ibm.commerce.foundation.logging.service.UELogger=fine:com.ibm.commerce.*=detail"}' http://9.112.245.166:8200/v1/demo/qa/auth/traceSpecification/ts-app

You can use this command to check if the trace level is correct on Vault:
curl -X GET -H "X-Vault-Token:26d57e48-622b-2fc1-d4b5-e88181914f86" http://9.112.245.166:8200/v1/demo/qa/auth/traceSpecification/ts-app


1. Change red part to the trace level you want
2. Change the blue part the the target environment
3. Change the green part to the target component ( ts-app/ search-app / crs-app /xc-app )


After that, you can deploy Commerce through Jenkins, you will see the log when start up docker in DC/OS log
