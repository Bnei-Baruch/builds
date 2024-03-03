#!/bin/bash
# cd /usr/src
# git clone https://github.com/Bnei-Baruch/builds.git

BUILD_CONTAINER=$1
ARTIFACT_NAME=$2
ARTIFACT_VER=$3

docker run \
-v /usr/src:/usr/src \
-v /artifacts:/artifacts \
-e ARTIFACT_VER="$ARTIFACT_VER" \
${BUILD_CONTAINER} \
/bin/bash /usr/src/${ARTIFACT_NAME}/build_${ARTIFACT_NAME}.sh
