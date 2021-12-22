#!/usr/bin/bash

declare -a serverList=()

function usage {
    echo "usage: $0 <value> <server list>"

    echo "example usage:"
    echo "scale.sh 2 ts"
    echo "scale.sh 3 crs ts"
    echo "scale.sh all"
    echo "server list can contain: ts, crs, search-slave, search-rpt, xc, web"
    exit 1
}


function scale() {

    # get length of an array
    arraylength=${#serverList[@]}

    for (( i=1; i<${arraylength}+1; i++ ));
    do
    #echo $i " / " ${arraylength} " : " ${serverList[$i-1]}
    server=${serverList[$i-1]}
    #echo "scaling server" $server
       # select server
       case $server in 
         livetsapp)
             #echo -n "livets-ap"
             kube_output=$(kubectl scale deployment demoqalivets-app --replicas=$value -n commerce)
             echo "kube_output: " $kube_output
             ;;
         authtsapp)
             #echo -n "authts-ap"
             kube_output=$(kubectl scale deployment demoqaauthts-app --replicas=$value -n commerce)
             echo "kube_output: " $kube_output
             ;;
         crs)
             #echo -n "crs-app"
             kube_output=$(kubectl scale deployment demoqalivecrs-app --replicas=$value -n commerce)
             echo "kube_output: " $kube_output
             ;;
         search)
	     #echo -n "search-app-slave"
             kube_output=$(kubectl scale deployment demoqalivesearch-app-slave --replicas=$value -n commerce)
             echo "kube_output: " $kube_output
             ;;
         livetsweb)
             #echo -n "livets-web"
             kube_output=$(kubectl scale deployment demoqalivets-web --replicas=$value -n commerce)
             echo "kube_output: " $kube_output
             ;;
         livestore)
             #echo -n "livestore-web"
             kube_output=$(kubectl scale deployment demoqalivestore-web --replicas=$value -n commerce)
             echo "kube_output: " $kube_output
             ;;
         authtsweb)
             #echo -n "authts-web"
             kube_output=$(kubectl scale deployment demoqaauthts-web --replicas=$value -n commerce)
             echo "kube_output: " $kube_output
             ;;
         authstore)
             #echo -n "authstore-web"
             kube_output=$(kubectl scale deployment demoqaauthstore-web --replicas=$value -n commerce)
             echo "kube_output: " $kube_output
             ;;
         nifi)
             #echo -n "nifi-app"
             kube_output=$(kubectl scale deployment demoqanifi-app --replicas=$value -n commerce)
             echo "kube_output: " $kube_output
             ;;
         ingest)
             #echo -n "ingest-app"
             kube_output=$(kubectl scale deployment demoqaingest-app --replicas=$value -n commerce)
             echo "kube_output: " $kube_output
             ;;
         registry)
             #echo -n "registry-app"
             kube_output=$(kubectl scale deployment demoqaregistry-app --replicas=$value -n commerce)
             echo "kube_output: " $kube_output
             ;;
         tooling)
             #echo -n "tooling-web"
             kube_output=$(kubectl scale deployment demoqatooling-web --replicas=$value -n commerce)
             echo "kube_output: " $kube_output
             ;;
         sharequery)
             #echo -n "query-app"
             kube_output=$(kubectl scale deployment demoqaquery-app --replicas=$value -n commerce)
             echo "kube_output: " $kube_output
             ;;
         livequery)
             #echo -n "livequery-app"
             kube_output=$(kubectl scale deployment demoqalivequery-app --replicas=$value -n commerce)
             echo "kube_output: " $kube_output
             ;;
         authquery)
             #echo -n "authquery-app"
             kube_output=$(kubectl scale deployment demoqaauthquery-app --replicas=$value -n commerce)
             echo "kube_output: " $kube_output
             ;;
         rptr)
             echo -n "ts-web"
             kube_output=$(kubectl scale deployment demoqalivesearch-app-repeater --replicas=$value -n commerce)
             echo "kube_output: " $kube_output
             ;;
         all)
             echo -n "all"
	     #kubectl scale deployment demoqalivets-app -replicas=1 -n commerce
             kube_output=$(kubectl scale deployment demoqalivets-app --replicas=$value -n commerce)
             echo "kube_output: " $kube_output
	     #kubectl scale deployment demoqalivecrs-app --replicas=1 -n commerce
             kube_output=$(kubectl scale deployment demoqalivecrs-app --replicas=$value -n commerce)
             echo "kube_output: " $kube_output
	     #kubectl scale deployment demoqalivets-app --replicas=1 -n commerce
             kube_output=$(kubectl scale deployment demoqalivesearch-app-slave --replicas=$value -n commerce)
             echo "kube_output: " $kube_output
	     #kubectl scale deployment demoqalivets-web --replicas=1 -n commerce
             kube_output=$(kubectl scale deployment demoqalivets-web --replicas=$value -n commerce)
             echo "kube_output: " $kube_output
             ;;
       esac
    done
}

    args=("$@")
    if [ "$#" -lt 2 ]; then
       echo "Invalid number of parameters"
       usage
    fi

    #Parse Value Paramater
    value=${args[0]}
    re='^[0-9]+$'
    if ! [[ $value =~ $re ]] ; then
       echo "error: Scale Value is not a number" >&2; exit 1
    fi

    while [ -n "$2" ]; do
       echo " adding " $2
       serverList+=($2)
       shift
    done
   
    scale
