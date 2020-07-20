#!/usr/bin/env bash

WHOAMI=`python -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' $0`
DIR=`dirname $WHOAMI`
PROJECT=`dirname $DIR`
ALIAS='woeplanet'
INDEX_DATE=`date +"%Y%m%d"`
PREV_INDEX_DATE=${INDEX_DATE}
ES='localhost:9200'
ESVERSION=7.7
HDR="Content-Type: application/json"

if [ -z "$1" ]; then
    echo "Usage: reload-schema.sh [woeplanet|placetypes] [YYMMDD]"
    exit 1
fi

if [ ! -z "$2" ]; then
    PREV_INDEX_DATE="${2}"
fi

if [ "$1" = 'placetypes' ]; then
    ALIAS='placetypes'
elif [ "$1" != 'woeplanet' ]; then
    echo "Usage: reload-schema.sh [woeplanet|placetypes] [YYMMDD]"
    exit 1
fi

PREV_INDEX="${ALIAS}_${PREV_INDEX_DATE}"
INDEX="${ALIAS}_${INDEX_DATE}"

echo "Deleting index '${PREV_INDEX}'"
curl -s -XDELETE "${ES}/${PREV_INDEX}" | python -mjson.tool

echo "Creating index '${INDEX}'"
cat ${PROJECT}/schema/${ESVERSION}/mappings.${ALIAS}.json | curl -s -XPUT ${ES}/${INDEX} -H "${HDR}" -d @- | python -mjson.tool

echo "Aliasing '${INDEX}' as '${ALIAS}'"
curl -s -XPOST ${ES}/_aliases -H "${HDR}" -d "{\"actions\":[{\"add\":{\"alias\": \"${ALIAS}\", \"index\": \"${INDEX}\"}}]}" | python -mjson.tool
