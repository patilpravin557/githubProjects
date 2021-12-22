#!/usr/bin/bash

#Usage: hclogs <app type> <container name>
#ex. hclogs crs demoqalivecrs-app-77fd445d5d-crdsz

#Parse Value Paramater
app=$1
container=$2

mkdir ./tmp
cd ./tmp

if [[ $app == "ts" ]]
then
  mkdir ts
  cd ts
  kubectl cp commerce/$container:/opt/WebSphere/AppServer/profiles/default/logs/container/ts_$container .
  mkdir healthcenter
  cd healthcenter
  kubectl exec -it $container -- ls -ltr /profile/logs/healthcenter >> ./healthCenter.log.timestamp.out
  kubectl cp commerce/$container:/profile/logs/healthcenter .
  cd ../..
elif [[ $app == "crs" ]]
then
  mkdir crs
  cd crs
  kubectl cp commerce/$container:/opt/WebSphere/Liberty/usr/servers/default/logs/container/store_$container .
  mkdir healthcenter
  cd healthcenter
  kubectl exec -it $container -- ls -ltr /profile/logs/healthcenter >> ./healthCenter.log.timestamp.out
  kubectl cp commerce/$container:/profile/logs/healthcenter .
  cd ../..
elif [[ $app == "search" ]]
then
  mkdir search
  cd search
  kubectl cp commerce/$container:/opt/WebSphere/Liberty/usr/servers/default/logs/container/search_$container .
  mkdir healthcenter
  cd healthcenter
  kubectl exec -it $container -- ls -ltr /profile/logs/healthcenter >> ./healthCenter.log.timestamp.out
  kubectl cp commerce/$container:/profile/logs/healthcenter .
  cd ../..
else
  exit
fi

cd ..
zip -r $container.zip ./tmp/* log.timestamp.out
rm -rf ./tmp
