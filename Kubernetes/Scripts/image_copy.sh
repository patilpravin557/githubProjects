#!/bin/bash

# Andres
# 202-02-19

# if you remove the hard-coded value, 
# it needs to be set in the parameter
TEST_NAME=
# Change source image path to use a 
# different fix pack
SOURCE_IMAGE_PATH=9.1.7.0

TARGET_IMAGE_PATH=performance/testing/
REPO=comlnx94.prod.hclpnp.com


if [[ -n "$1" ]]; then
  TEST_NAME=$1
fi

if [[ -n "$TEST_NAME" ]]; then
  TARGET_IMAGE_PATH=${TARGET_IMAGE_PATH}${TEST_NAME}
  echo "** Copying images to $TARGET_IMAGE_PATH"
else
  echo "** Invalid usage. specify test name"
  exit -1
fi

declare -a COMMERCE_IMAGES=(
    "ts-db:v9-latest"
    "tooling-web:v9-latest"
    "store-web:v9-latest"
    "ts-web:v9-latest"
    "crs-app:v9-latest"
    "search-app:v9-latest"
    "search-ingest-app:v9-latest"
    "search-query-app:v9-latest"
    "ts-app:v9-latest"
    "search-nifi-app:v9-latest"
    "search-query-app:v9-latest"
    "search-registry-app:v9-latest"
    "xc-app:v9-latest"
    "supportcontainer:v9-latest"
    "cache-app:v9-latest" )

for IMAGE in "${COMMERCE_IMAGES[@]}"
do
  
  FULL_IMAGE_SOURCE_PATH=${REPO}/${SOURCE_IMAGE_PATH}/${IMAGE}
  FULL_IMAGE_TARGET_PATH=${REPO}/${TARGET_IMAGE_PATH}/${IMAGE}

  echo "** Processing $FULL_IMAGE_SOURCE_PATH to $FULL_IMAGE_TARGET_PATH"
  
  docker pull ${FULL_IMAGE_SOURCE_PATH}
  docker tag ${FULL_IMAGE_SOURCE_PATH} ${FULL_IMAGE_TARGET_PATH}
  docker push ${FULL_IMAGE_TARGET_PATH}  
  
  # optional. deleting local images to free up space
  docker rmi ${FULL_IMAGE_SOURCE_PATH}
  docker rmi ${FULL_IMAGE_TARGET_PATH}

done

echo "** Done.."
