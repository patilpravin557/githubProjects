## source docker registry namespace/library
NAMESPACE="9.1.7.0"

## image tag, use v9-latest to get latest images, otherwise use the specified tag
## When v9-latest is specified, images with both timestamp tag and v9-latest tag will be pushed
TAG="v9-latest"

## custom build store-web to include google verify file and site map
CUST_STORE=true

## custom image for oracle
BUILD_ORACLE=true

## custom image for onedb
BUILD_ONEDB=true

## custom image for LDAP IDS
BUILD_IDS=true

## custom image for LDAP AD
BUILD_AD=false

## delete pulled docker image after each push
CLEAN_LOCAL=true

## docker image names to pull and push
IMAGE_LIST="ts-db ts-app ts-web search-app crs-app xc-app tooling-web search-query-app search-ingest-app search-registry-app search-nifi-app store-web ts-utils ts-oracle ts-onedb"
#IMAGE_LIST="ts-db ts-app ts-web search-app crs-app xc-app tooling-web"
#IMAGE_LIST="search-query-app search-ingest-app search-registry-app search-nifi-app store-web"
#IMAGE_LIST="ts-utils"
#IMAGE_LIST="supportcontainer"
#IMAGE_LIST=""

## Overwrite Destination Tag. This is usually used when pushing 901 release images.
## When DEST_TAG is set, all images pushed to gcr will be tagged with this tag
#DEST_TAG="9.0.1.14"

## Specific source image tags. 
## These image tags will take precedence if specified (non-empty)
## otherwise, it will use the global TAG or resolve the latest timestamp tag if TAG=v9-latest
declare -A SOURCE_IMAGE_TAGS=(\
    ["ts-db"]="" \
    ["ts-app"]=""\
    ["ts-web"]=""\
    ["search-app"]=""\
    ["crs-app"]=""\
    ["xc-app"]=""\
    ["tooling-web"]=""\
    ["search-query-app"]=""\
    ["search-ingest-app"]=""\
    ["search-registry-app"]=""\
    ["search-nifi-app"]=""\
    ["store-web"]=""\
    ["ts-utils"]=""\
    ["supportcontainer"]="" \
)

###########################
# DO NOT CHANGE FOLLOWING #
###########################

## Namespace mapping from internal HCL docker registry to gcr
declare -A NAMESPACE_MAP=(\
    ["9.1.7.0"]="performance/pravin/9.1.7.0"\
    )

## source docker registry
SOURCE_REGISTRY="comlnx94.prod.hclpnp.com"

## destination docker registry
DEST_REGISTRY="us.gcr.io/commerce-product"
