- restore my db 180K in gcp 

- I will give you the csv files for 180K 

- deploy util docker in gcp (may be you need to install docker-compose) 

Use this yaml file to create util  

utils: 
image: utility:latest 
hostname: auth_utils 
environment: 
- LICENSE=accept 
- DBHOST=db 
- DBNAME=mall 
- DBPORT=50000 
- DBUSER=wcs 
- DBADMIN=db2inst1 
- ENABLE_DB_SSL=false 
tty: true 
healthcheck: 
test: exit 0 
working_dir: /opt/WebSphere/CommerceServer90/bin 

- copy the 180K dataset csv inside docker 

- change wc-dataload-env.xml to point to your db 

- Run the command to change N items on both files CatalogEntry.csv and CatalogEntryDescription.csv 

- Run dataload by going inside util docker and run ./dataload.sh /root/dataset_gcp_180K/wc-dataload-all.xml 

 

 

Recording 

 

https://hclo365-my.sharepoint.com/:v:/g/personal/pravinprakash_patil_hcl_com/EbcA8jmQpN1NtZxMGFnaP3ABFg4xdH-BRCyoqN7v306mfg 

 

https://hclo365-my.sharepoint.com/personal/vijayalakshmi_k_hcl_com1/_layouts/15/onedrive.aspx?id=%2Fpersonal%2Fvijayalakshmi%5Fk%5Fhcl%5Fcom1%2FDocuments%2FRecordings%2Fdataset%5Fgenerator%20new%20enhancements%2D20210608%5F200338%2DMeeting%20Recording%2Emp4&parent=%2Fpersonal%2Fvijayalakshmi%5Fk%5Fhcl%5Fcom1%2FDocuments%2FRecordings&originalPath=aHR0cHM6Ly9oY2xvMzY1LW15LnNoYXJlcG9pbnQuY29tLzp2Oi9nL3BlcnNvbmFsL3ZpamF5YWxha3NobWlfa19oY2xfY29tMS9FYlVmTDdfRFN4NUppcmVwMTYwbVdmSUJ2ZHB5NHpzb3NUZmgxbmY2MGo0bUdRP3J0aW1lPVFrQWQ2cjVOMlVn 

 

https://hclo365-my.sharepoint.com/personal/pravinprakash_patil_hcl_com/_layouts/15/onedrive.aspx?id=%2Fpersonal%2Fpravinprakash%5Fpatil%5Fhcl%5Fcom%2FDocuments%2FRecordings%2FCall%20with%20Noureddine%20Brahimi%2D20210520%5F203043%2DMeeting%20Recording%2Emp4&parent=%2Fpersonal%2Fpravinprakash%5Fpatil%5Fhcl%5Fcom%2FDocuments%2FRecordings&originalPath=aHR0cHM6Ly9oY2xvMzY1LW15LnNoYXJlcG9pbnQuY29tLzp2Oi9nL3BlcnNvbmFsL3ByYXZpbnByYWthc2hfcGF0aWxfaGNsX2NvbS9FVURKSDdScDNyaElzb2EzWGlRdS1oNEJqUjllLUVLeW1XVHB4X05zQ2E4UjNBP3J0aW1lPXM3c1dOejRxMlVn 

 

 

head -n 3 example.csv | sed -E 's/ term([0-9]+),/ test_0001 term\1,/' 

 

 

 

On db server 

 

[root@perf-cluster-2-db2 ~]# docker ps 

CONTAINER ID        IMAGE                                                              COMMAND                  CREATED             STATUS              PORTS                          NAMES 

57d2afe58e60        us.gcr.io/commerce-product/performance/pravin/ts-utils:v9-latest   "/SETUP/bin/entryp..."   23 hours ago        Up 23 hours         5080/tcp, 5280/tcp, 5443/tcp   tmp_utils_1 

[root@perf-cluster-2-db2 ~]# 

  

  

docker cp dataset_180k/ tmp_utils_1:/root/ 

 

docker exec -it 57d2afe58e60 bash 

 

[root@auth_utils bin]# pwd 

/opt/WebSphere/CommerceServer90/bin 

[root@auth_utils bin]# 

 

[root@auth_utils tmp]# ll 

total 550780 

-rw-r--r--. 1 root root     17616 Jun  8 13:35 1 

-rw-r--r--. 1 root root 287751339 Jun  8 12:57 CatalogEntry.csv 

-rw-r--r--. 1 root root 276172896 Jun  8 13:36 CatalogEntryDescription.csv 

-rwxrwxrwx. 1 root root       570 Jun  8 13:43 connlicj.bin 

-rw-r--r--. 1 root root     17616 Jun  8 13:34 file_CatalogEntry_20.csv 

-rw-r--r--. 1 root root     16508 Jun  8 13:37 file_CatalogEntryDescription_20.csv 

-rwxrwxrwx. 1 root root       205 Jun  8 13:43 jccdiag.log 

-rwxrwxrwx. 1 root root         0 Jun  8 13:43 license.lock 

[root@auth_utils tmp]# 

  

 

[root@auth_utils ~]# ls 

anaconda-ks.cfg  dataset_180k 

[root@auth_utils ~]# 

 

***Runndataload ************** 

[root@perf-cluster-2-db2 ~]# docker ps 

CONTAINER ID        IMAGE                                                              COMMAND                  CREATED             STATUS              PORTS                          NAMES 

57d2afe58e60        us.gcr.io/commerce-product/performance/pravin/ts-utils:v9-latest   "/SETUP/bin/entryp..."   23 hours ago        Up 23 hours         5080/tcp, 5280/tcp, 5443/tcp   tmp_utils_1 

[root@perf-cluster-2-db2 ~]# docker exec -it 57d2afe58e60 bash 

[root@auth_utils bin]# ./dataload.sh /root/dataset_180k/wc-dataload-all.xml 

2021-06-09 08:42:42.164 INFO    com.ibm.commerce.foundation.dataload.DataLoaderMain displayHeader 

================================================================================== 

HCL Commerce Data Load 

================================================================================== 

  

2021-06-09 08:42:42.214 INFO    com.ibm.commerce.foundation.dataload.DataLoaderMain logStartDate Load started at: Wed Jun 09 08:42:42 GMT 2021 

Please enter the database user password: wcs1 

 

 

 

 

***From Masood************ 

 

 

[19-Mar 20:38] Noureddine Brahimi 
yes, we have a tool that generates csv file to be used by dataload tool to load catalog into commerce 
let me find the link for you 
[19-Mar 20:43] Noureddine Brahimi 
https://github01.hclpnp.com/commerce-dev/performance-assets/tree/master/dataset_generator/20210319 
[19-Mar 20:43] Noureddine Brahimi 
download the files, put them under the same folder and change dataset.cfg based on your need and run the exe file 
[19-Mar 20:44] Masood Khan 
Thanks 
[19-Mar 20:44] Noureddine Brahimi 
2 folders will be generated upload_add and upload_del  
[19-Mar 20:44] Noureddine Brahimi 
 
use the one under upload_add to load data  
[19-Mar 20:44] Noureddine Brahimi 
welcome 
[19-Mar 20:45] Masood Khan 
any parameter for the exe , i assume no i have to run it and it will pick up the cfg file from the same location  

[19-Mar 20:45] Noureddine Brahimi 
correct 
[19-Mar 20:45] Masood Khan 
perfect..!!  
[19-Mar 20:46] Noureddine Brahimi 
the exe generates the csv files but do not do the load itself. To load you need to run dataload using the csv files 
[19-Mar 20:47] Masood Khan 
ok, thanks 
[19-Mar 20:47] Noureddine Brahimi 
np  
[19-Mar 20:56] Masood Khan 
path_to_language_files = D:\GenerateDataset\dict  
This seems to be not available,  

I got this  

Loading language files 
Loading English language words - Duration: 0s 
2021/03/19 20:52:58 The path for the language files is not correct or the files are not there. Check path_to_language_files parameter in the cfg file. open D:\GenerateDataset\dict\en.dic: The system cannot find the path specified. 
[19-Mar 20:57] Noureddine Brahimi 
sorry, I forget to check in the language files. let me do it  
[19-Mar 20:57] Masood Khan 
alright 
[19-Mar 21:03] Noureddine Brahimi 
 
download dict folder from the same location and set the parameter path_to_language_files to its folder 
