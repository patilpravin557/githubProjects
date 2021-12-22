#!/bin/bash

# push-to-live connector

DOMAIN=.andres.svt.hcl.com
COMMERCE_TENANT=demo
COMMERCE_ENV_NAME=qa
COMMERCE_STORE_ID=11


function log {
  echo "** [`date`] $@"
}

log ""
log ""
log "Runnning connector push-to-live ...."
log ""
log ""

SECONDS=0

# curl -X POST -H "accept: */*" "http://ingest.demoqa.andres.svt.hcl.com/connectors/push-to-live/run?storeId=11&envType=live"

curl_resp=`curl -w 'http_code:%{http_code}' -v -X POST -H "accept: */*" "http://ingest.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${DOMAIN}/connectors/push-to-live/run?storeId=$COMMERCE_STORE_ID&envType=live"`
log "$curl_resp"

curl_http_status=`echo $curl_resp | sed 's/.*http_code://g'`
if [ "$curl_http_status" -ne 202 ]
then
  log "ERROR: POST /connectors/push-to-live/run: Unexpected http status response: $curl_http_status"
  exit 1
fi

curl_json=`echo $curl_resp | sed 's/http_code:.*//g'`    
push_to_live_run_id=`echo $curl_json | python -c "import sys, json; print(json.load(sys.stdin)['runId'])"`

log "Push-to_Live running: runId: $push_to_live_run_id"
 
 #
 # Monitoring connector run progress
 # ----------------------------------------------------------------------------
 
 #{
 #    "date": "2020-10-23T17:00:29.848Z",
 #    "runId": "607ccc5b-28bc-4332-a810-898bd23643ff",
 #    "fromType": "summary",
 #    "message": "Indexing run finished according to Nifi queue being empty for given connector.{\"elapsed\":119,\"codes\":{\"DI1010W\":3},\"start\":\"2020-10-23T16:58:30.018Z\",\"run\":\"607ccc5b-28bc-4332-a810-898bd23643ff\",\"end\":\"2020-10-23T17:00:29.572Z\",\"locations\":{\"warning\":{\"STA Stage 1 (Database), Load STA\":{\"W\":2},\"STA Stage 1 (Database), Find STA\":{\"W\":1}}},\"severities\":{\"W\":3}}",
 #    "status": 0
 #}
 
 push_to_live_completed=0
 push_to_live_run_loop_num=0
 
 # 10 hours
 while [ $push_to_live_completed -eq 0 ] && [ $push_to_live_run_loop_num -lt 600 ]
 do      
   # /connectors/{connectorId}/runs/{runId}/status
   curl_resp=`curl -s -w 'http_code:%{http_code}' -X GET -H "accept: */*" "http://ingest.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${DOMAIN}/connectors/push-to-live/runs/${push_to_live_run_id}/status"`
   if [ $? -eq 0 ]; then
	 curl_http_status=`echo $curl_resp | sed 's/.*http_code://g'`
	 if [ "$curl_http_status" -eq 200 ]; then
	 
	   curl_json=`echo $curl_resp | sed 's/http_code:.*//g'`
	 
	   json_status=`echo $curl_json | python -c "import sys, json; print(json.load(sys.stdin)['status'])"`
	   json_message=`echo $curl_json | python -c "import sys, json; print(json.load(sys.stdin)['message'])"`
	   
	   log "push-to-live: status: $json_status $json_message"
	   if [ "$json_status" -eq 0 ]
	   then
		 duration=$SECONDS
		 commerce_connector_creation_end_epoch=`date +'%s'`000
		 push_to_live_completed=1
		 
		 log "Push-to-live completed with status 0 in $(($duration / 60)) minutes"
		 
	   else            
		 sleep 20
	   fi
	 else	 
	   log "ERROR: GET http://ingest.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${DOMAIN}/connectors/push-to-live/runs/${push_to_live_run_id}/status"
	   log "ERROR: Unexpected http status response: $curl_http_status"
	   log "ERROR: $curl_resp"
	   exit 1
	 fi

   else
	  log " ERROR: Unable to check connector run status: $curl_resp"
	  exit 1
   fi
   let loop_num=$push_to_live_run_loop_num+1
 done
 
 if [ $push_to_live_completed -eq 0 ]
 then
   log "ERROR Push-to-live didn't complete successfully"
   exit 1
 fi

exit 0
