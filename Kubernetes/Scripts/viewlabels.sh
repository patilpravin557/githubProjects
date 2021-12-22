#!/usr/bin/bash

#kubectl exec demoqalivecrs-app-57685d8465-2zxbt -n commerce --container crs-app  -- viewlabels
#kubectl exec demoqalivesearch-app-repeater-b7d9765c5-wchfk -n commerce --container search-app-repeater -- viewlabels
#kubectl exec demoqalivesearch-app-slave-b4c745f9d-h9v6s -n commerce --container search-app-slave -- viewlabels
#kubectl exec demoqalivets-app-5b679f6884-xvgdn -n commerce --container  ts-app -- viewlabels
#kubectl exec demoqalivets-web-75f59b4d6f-576vx -n commerce --container ts-web  -- viewlabels
#
#loop through json path, match server type with regex and exec viewlabels

if [[ $# -ne 3 ]]
then 
 	echo "Usage: $0 tenantName envName envType"
	echo "For example, $0 demo qa live"
	exit
fi

env1="$1$2"
env2="$env1$3"

commandName="kubectl get pod -n commerce -o jsonpath='{.items[0].metadata.name}'"
temp=$($commandName 2>/dev/null)
if [[ $? == 0 ]] 
then
	containerName=`echo $temp|sed -e "s/'//g"`
else
	containerName="none"
fi

if [[ $containerName != *$env1* ]]
then
	echo "Incorrect Tenant/EnvName specified"
	exit
fi

x=1

while [[ $containerName != "none" ]]
do
        commandName="kubectl get pod -n commerce -o jsonpath='{.items[$x].metadata.name}'"
	temp=$($commandName 2>/dev/null)
        if [[ $? == 0 ]] 
        then
		containerName=`echo $temp|sed -e "s/'//g"`
        else
		containerName="none"
	fi

        #echo "temp=$temp"
	#echo "commandName=$commandName"

	if [[ $containerName != *"wcs-post"* ]] && [[ $containerName != *"wcs-pre"* ]] && [[ $containerName != "none" ]]
        then
        	echo "containerName=$containerName"
	fi

        if [[ $containerName =~ $env2"ts-app" ]]
        then
                echo $(kubectl exec $containerName -n commerce --container  ts-app -- viewlabels)
        elif [[ $containerName =~ $env2"crs-app" ]]
        then
                echo $(kubectl exec $containerName -n commerce --container crs-app  -- viewlabels)
        elif [[ $containerName =~ $env2"search-app" ]]
        then
                echo $(kubectl exec $containerName -n commerce --container search-app-repeater -- viewlabels)
        elif [[ $containerName =~ $env2"ts-web" ]]
        then
                echo $(kubectl exec $containerName -n commerce --container ts-web  -- viewlabels)
        elif [[ $containerName =~ $env2"store-web" ]]
        then
                echo $(kubectl exec $containerName -n commerce --container store-web -- viewlabels)
        elif [[ $containerName =~ $env2"query-app" ]]
        then
                echo $(kubectl exec $containerName -n commerce --container query-app -- viewlabels)
        elif [[ $containerName =~ $env1"query-app" ]]
        then
                echo $(kubectl exec $containerName -n commerce --container query-app  -- viewlabels)
        elif [[ $containerName =~ $env1"ingest-app" ]]
        then
                echo $(kubectl exec $containerName -n commerce --container ingest-app -- viewlabels)
        elif [[ $containerName =~ $env1"nifi-app" ]]
        then
                echo $(kubectl exec $containerName -n commerce --container nifi-app -- viewlabels)
        elif [[ $containerName =~ $env1"registry-app" ]]
        then
                echo $(kubectl exec $containerName -n commerce --container registry-app -- viewlabels)
        elif [[ $containerName =~ $env1"tooling-web" ]]
        then
                echo $(kubectl exec $containerName -n commerce --container tooling-web -- viewlabels)
        fi

	let x=$x+1

done
