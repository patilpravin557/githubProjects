#!/bin/bash

#  Foreground:
#   ./etcd_test.sh  2>&1 | tee etcd_test.log
#
#  Background: (can close terminal)
#    nohup ./etcd_test.sh &> etcd_test.log &

INTERVAL=3
# 24 hours
MAX_SECONDS=86400

echo "** kubectl/etcd test - $INTERVAL seconds sleep"

SECONDS=0
TEMP_LOG_FILE=/tmp/etcd_$$.tmp

while [ $SECONDS -lt $MAX_SECONDS ]
do

  # log date every minute
  if [ $SECONDS -gt 60 ]; then
    echo ""
    echo "** "`date`
    SECONDS=0
  fi

  kubectl get pods > $TEMP_LOG_FILE 2>&1
  if [ $? -ne 0 ]; then
    echo ""
    echo "** "`date`" kubectl failed"
  fi

  grep -q etcd $TEMP_LOG_FILE
  if [ $? -eq 0 ]; then
    echo "** "`date`" "`cat $TEMP_LOG_FILE`
  fi

  echo -n "."
  sleep $INTERVAL

done
