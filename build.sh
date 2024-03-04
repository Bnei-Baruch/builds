#!/bin/bash

BUILD_CONTAINER=$1
ARTIFACT_NAME=$2
ARTIFACT_VER=$3

docker run \
-v /usr/src/builds/${ARTIFACT_NAME}:/usr/src/builds/${ARTIFACT_NAME} \
-v /artifacts:/artifacts \
-e ARTIFACT_VER="$ARTIFACT_VER" \
-e BUILD_CONTAINER="$BUILD_CONTAINER" \
${BUILD_CONTAINER} \
/bin/bash /usr/src/builds/${ARTIFACT_NAME}/build_${ARTIFACT_NAME}.sh
