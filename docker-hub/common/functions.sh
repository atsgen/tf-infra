#!/bin/bash
#
# common functions for docker utilities
# note:
#   usage: source $(dirname $0)/common/functions.sh
# Maintainer: prabhjot@atsgen.com

REPO_LIST=''
get_repos() {
  local work=1
  local URL="https://hub.docker.com/v2/repositories/${DOMAIN}/?page_size=100"
  while [ $work -ne 0 ]; do
    local RESP=$(curl -s -H "Authorization: JWT ${TOKEN}" $URL)
    URL=$(echo $RESP | jq -r '.next')
    REPO_LIST="${REPO_LIST} $(echo $RESP | jq -r '.results|.[]|.name')"
    if [[ -z "$URL" || "x$URL" == "xnull" ]]; then
      work=0
    fi
  done
}
