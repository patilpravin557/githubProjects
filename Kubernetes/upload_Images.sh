#!/bin/bash
###########################################################################
# Make sure you have following command executed before running this script
# gcloud auth login
# gcloud auth configure-docker
###########################################################################

source ./config.sh

## push image with the specified name and tag
## Input:
##   1 - image name
##   2 - source tag
##   3 - destination tag
##   4 - v9-latest
function pushImageToGCR() {
    name=$1
    source_tag=$2
    dest_tag=$3
    latest=$4

    echo "Pushing $DEST_REGISTRY/$dest_ns/$name:$dest_tag"
    docker tag $SOURCE_REGISTRY/$NAMESPACE/$name:$source_tag $DEST_REGISTRY/$dest_ns/$name:$dest_tag
    docker push $DEST_REGISTRY/$dest_ns/$name:$dest_tag
    if [ "$?" != "0" ]
    then
        echo "failed to push docker image $DEST_REGISTRY/$dest_ns/$name:$dest_tag"
        exit 1
    fi
    echo ""

    if [ "$latest" = "v9-latest" ]; then
        echo "Pushing $DEST_REGISTRY/$dest_ns/$name:v9-latest"
        docker tag $SOURCE_REGISTRY/$NAMESPACE/$name:$source_tag $DEST_REGISTRY/$dest_ns/$name:v9-latest
        docker push $DEST_REGISTRY/$dest_ns/$name:v9-latest
        if [ "$?" != "0" ]
        then
            echo "failed to push docker image $DEST_REGISTRY/$dest_ns/$name:v9-latest"
            exit 1
        fi
        echo ""
    fi

    if [ "$CLEAN_LOCAL" = "true" ]; then
        echo "Removing local image"
        if [ "$latest" = "v9-latest" ]; then
            docker rmi $DEST_REGISTRY/$dest_ns/$name:v9-latest
            echo ""
        fi
        docker rmi $DEST_REGISTRY/$dest_ns/$name:$dest_tag
        docker rmi $SOURCE_REGISTRY/$NAMESPACE/$name:$source_tag
        echo ""
    fi
}

## resolve destination namespace based on the mapping defined in NAMESPACE_MAP
## dest_ns will be set after function call
function resolveDestNamespace() {
    if [ -z "${NAMESPACE_MAP[$NAMESPACE]}" ]
    then
        dest_ns=$NAMESPACE
    else
        dest_ns=${NAMESPACE_MAP[$NAMESPACE]}
    fi
}

## Build OneDB docker image and push to GCR
function buildAndPushOneDBDockerImageToGCR() {
    if [ "$BUILD_ONEDB" = "true" ]; then
        if [ "$img_name" = "ts-app" ] || [ "$img_name" = "search-nifi-app" ]; then
            cp $img_name-onedb/Dockerfile.template $img_name-onedb/Dockerfile
            sed -i "s/<tag>/$tag/g" $img_name-onedb/Dockerfile
            sed -i "s/<registry>/$SOURCE_REGISTRY/g" $img_name-onedb/Dockerfile
            sed -i "s/<namespace>/$NAMESPACE/g" $img_name-onedb/Dockerfile
            cust_tag_onedb=$tag-onedb
            docker build -t $SOURCE_REGISTRY/$NAMESPACE/$img_name:$cust_tag_onedb $img_name-onedb
            pushImageToGCR $img_name $cust_tag_onedb $cust_tag_onedb
        fi
    fi
}

## Build customized ts-app for LDAP IDS and push to GCR
function buildAndPushIdsDockerImageToGCR() {
    if [ "$BUILD_IDS" = "true" ] && [ "$img_name" = "ts-app" ]; then
        cp ts-app-ids/Dockerfile.template ts-app-ids/Dockerfile
        sed -i "s/<tag>/$tag/g" ts-app-ids/Dockerfile
        sed -i "s/<registry>/$SOURCE_REGISTRY/g" ts-app-ids/Dockerfile
        sed -i "s/<namespace>/$NAMESPACE/g" ts-app-ids/Dockerfile

        cust_tag_ids=$tag-ids
        docker build -t $SOURCE_REGISTRY/$NAMESPACE/$img_name:$cust_tag_ids ts-app-ids
        pushImageToGCR $img_name $cust_tag_ids $cust_tag_ids
    fi
}

## Build cusomized ts-app for LDAP AD and push to GCR
function buildAndPushAdDockerImageToGCR() {
    if [ "$BUILD_AD" = "true" ] && [ "$img_name" = "ts-app" ]; then
        cp ts-app-ad/Dockerfile.template ts-app-ad/Dockerfile
        sed -i "s/<tag>/$tag/g" ts-app-ad/Dockerfile
        sed -i "s/<registry>/$SOURCE_REGISTRY/g" ts-app-ad/Dockerfile
        sed -i "s/<namespace>/$NAMESPACE/g" ts-app-ad/Dockerfile

        cust_tag_ad=$tag-ad
        docker build -t $SOURCE_REGISTRY/$NAMESPACE/$img_name:$cust_tag_ad ts-app-ad
        pushImageToGCR $img_name $cust_tag_ad $cust_tag_ad
    fi
}

##########
## Main ##
##########

## resolve destination namespace
resolveDestNamespace

## loop each specified image and push it to GCR
for img_name in $IMAGE_LIST
do
    if [ -n "${SOURCE_IMAGE_TAGS[$img_name]}" ]
    then
        tag=${SOURCE_IMAGE_TAGS[$img_name]}
    elif [ "$TAG" = "v9-latest" ]
    then
        tag=`curl -sS -X GET --insecure https://$SOURCE_REGISTRY/v2/${NAMESPACE}/${img_name}/tags/list?sort=true | jq -r .tags[] | sort -g | grep -E "v[0-9]-[0-9]{8}-[0-9]{4}.*" | tail -1`
    else
        tag=$TAG
    fi

    # validate tag make sure it is not empty 
    if [ -z "$tag" ]
    then
        echo "Invalid source image tag or namespace."
        exit 1
    fi

    # initialize cust_tag
    cust_tag=""

    # pull images from source registry
    echo "Pulling $SOURCE_REGISTRY/$NAMESPACE/$img_name:$tag"
    docker pull $SOURCE_REGISTRY/$NAMESPACE/$img_name:$tag
    if [ "$?" != "0" ]
    then
        echo "failed to pull docker image $SOURCE_REGISTRY/$NAMESPACE/$img_name:$tag"
        exit 1
    fi

    # handle custom image build
    if [ "$CUST_STORE" = "true" ] && [ "$img_name" = "store-web" ]
    then
        cp store-web/Dockerfile.template store-web/Dockerfile
        sed -i "s/<tag>/$tag/g" store-web/Dockerfile
        sed -i "s/<registry>/$SOURCE_REGISTRY/g" store-web/Dockerfile
        sed -i "s/<namespace>/$NAMESPACE/g" store-web/Dockerfile
        docker build -t $SOURCE_REGISTRY/$NAMESPACE/$img_name:$tag-cust store-web
        cust_tag=$tag-cust
    fi
    if [ "$BUILD_ORACLE" = "true" ]
    then
        if [ "$img_name" = "ts-app" ] || [ "$img_name" = "search-nifi-app" ] || [ "$img_name" = "search-app" ]
        then
            cp $img_name/Dockerfile.template $img_name/Dockerfile
            sed -i "s/<tag>/$tag/g" $img_name/Dockerfile
            sed -i "s/<registry>/$SOURCE_REGISTRY/g" $img_name/Dockerfile
            sed -i "s/<namespace>/$NAMESPACE/g" $img_name/Dockerfile
            docker build -t $SOURCE_REGISTRY/$NAMESPACE/$img_name:$tag-oracle $img_name
            cust_tag=$tag-oracle
        fi
    fi
	
    # tag and push original image
    if [ -n "$DEST_TAG" ]
    then
        pushImageToGCR $img_name $tag $DEST_TAG
    else
        pushImageToGCR $img_name $tag $tag $TAG
    fi

    # tag and push custom image
    if [ -n "$cust_tag" ]
    then
        pushImageToGCR $img_name $cust_tag $cust_tag
    fi

    buildAndPushOneDBDockerImageToGCR
    buildAndPushIdsDockerImageToGCR
    buildAndPushAdDockerImageToGCR
done
