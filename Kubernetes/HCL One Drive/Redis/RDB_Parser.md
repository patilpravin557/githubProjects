Hi, 

  

On Friday I worked on an utility to parse Redis dumps ( dump.rdb) 

  

It wasn’t that much work to be honest.  There are existing Java APIs/Frameworks to scan the contents of the file. 
https://github.com/jwhitbeck/java-rdb-parser 

  

See the sample report (attached). 

  

Features: 

Discover caches in the RBD file 

Count entries and estimate sizes 

Create a size histogram, to get a good idea of how big the entries are 

Show the cache key for the top 5 largest entries 

Show the top dependencies (by number of associated data id) 

  

I also plan to add options to dump a cache entry. E.g if a key is specified in the command line, we can print the contents. 

  

I was working with HP and noticed they had 20MB entries. I thought an utility like this is a good idea to see how common the 20mb entries are. 

  

I have a prototype (also attached), and I asked Masood if he can help me check it in. (and do the required build changes). 

  

I will need ideas for how we can make it available to customers. I can add it to the Performance Zip we have in FlexNet, but when we 
move to GitHub I am not sure if we can put binaries there.  

  

@Pravin Prakash Patil, Can you use the SAVE command and share the redis.dmp from one of your tests? I want to see how the report looks like. 

The rdb files I have are from my environment, not a Commerce server 

  

  

Thanks, 

  

Andres Voldman 

Performance Architect 

HCL Software 

 

[17:56] Andres Voldman 

Hi Pravin Prakash Patil, 

The fix for the rdb parser was released so I picked it up and released the rdb tool to the cache manager 

(1 liked) 

  

[17:57] Andres Voldman 

This is how you can run in my machine: 

 

kubectl cp dump.rdb.broken demoqalivecache-app-9b764c77b-657pl:/SETUP/hcl-cache/utilities/dump.rdb 
 

 

kubectl exec -it demoqalivecache-app-9b764c77b-657pl -- bash 
cd /SETUP/hcl-cache/utilities/ 
./hcl-cache-rdb.sh 
  

Can you please try this and also generate an rdb file from your run and run it thru the tool? 

 

  

[root@demoqalivecache-app-9b764c77b-657pl utilities]# ./hcl-cache-rdb.sh -h 

[Wed Jun 23 12:49:44 GMT 2021]    INFO: HCL Cache RDB Parser 20210623_0512 

[Wed Jun 23 12:49:44 GMT 2021]    INFO: -Xmx 1536mb 

usage: jar rdbparser.jar [options] 

-c,--cache <arg>       Cache name. Defaults to all 

-f,--file <arg>        RDB file. Defaults to dump.rdb in current 

                        directory 

-h,--help              Prints this help 

-k,--key <arg>         Dumps keys that contain the parameter. In this 

                        mode the report is not shown 

-n,--namespace <arg>   Namespace. Defaults to all 

[root@demoqalivecache-app-9b764c77b-657pl utilities]# 

 

./hcl-cache-rdb.sh -c baseCache 
