#!/bin/bash
#
# common script to trigger login
# note:
#   usage: source $(dirname $0)/common/login_token.sh
# Maintainer: prabhjot@atsgen.com

UNAME=''
UPASS=''

>&2 echo
>&2 echo
>&2 echo "Please use your Docker Hub ID to Authenticate"
>&2 echo "*********************************************"
>&2 echo -n "Username: " 
>&2 read UNAME
>&2 echo -n "Password: "
>&2 read -s UPASS
>&2 echo

TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${UNAME}'", "password": "'${UPASS}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token)

if [[ -z "$TOKEN" || "null" == "$TOKEN" ]]; then
  echo "failed to authenticate for user $UNAME"
  exit 1
fi

