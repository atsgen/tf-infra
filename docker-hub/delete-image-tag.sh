#!/bin/bash
#
# script to manage deletion of deprecated image:tags from docker hub
# Maintainer: prabhjot@atsgen.com
#
 
 
# filter repo pattern that you do not want to touch
FILTER=''
 
# delete empty repo
DELETE_EMPTY_REPO='True'
 
# tag to be deleted, change to the desired TAG to be deleted
TAG='test'
 
DOMAIN='atsgen'
 
# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

while getopts "h?t:d:f:" opt; do
    case "$opt" in
    h|\?)
        echo "$0   Usage: "
        echo "         -h  help"
        echo "         -t <TAG> image tag to be deleted eg. r5.1"
        echo "         -d <domain> domain from where image needs to be deleted eg. atsgen"
        echo "         -f <filter> repositories to skip"
        exit 0
        ;;
    t)  TAG=$OPTARG
        ;;
    d)  DOMAIN=$OPTARG
        ;;
    f)  FILTER=$OPTARG
        ;;
    esac
done

echo
echo "**************************************************************************"
if [[ -z "$FILTER" ]]; then
  echo "Deleting images with TAG $TAG, from Domain $DOMAIN."
else
  echo "Deleting images with TAG $TAG, from Domain $DOMAIN. while skipping $FILTER"
fi
echo "**************************************************************************"

source $(dirname $0)/common/login_token.sh
source $(dirname $0)/common/functions.sh

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

# get list of repositories for domain
get_repos
 
# iterate the list of repos to delete the mentioned tag for all repositories
for i in ${REPO_LIST}
do
  if [[ -z "$FILTER" || $i != *$FILTER* ]]; then
    # perform delete for the given tag
    RESULT=$(curl -s -X DELETE -H "Authorization: JWT ${TOKEN}" https://cloud.docker.com/v2/repositories/${DOMAIN}/${i}/tags/${TAG}/ | jq -r .detail)
    if [[ ! -z "$RESULT" ]]; then
      echo "$RESULT   $DOMAIN/$i:$TAG"
    else
      echo "Deleted   $DOMAIN/$i:$TAG"
      if [[ "xTrue" == "x$DELETE_EMPTY_REPO" ]]; then
        # check if this was the last tag in repo
        IMAGE_TAGS=$(curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${DOMAIN}/${i}/tags/?page_size=100 | jq -r '.results|.[]|.name')
        if [[ -z "$IMAGE_TAGS" ]]; then
          echo "Deleting empty repo $DOMAIN/$i"
          RESULT=$(curl -s -X DELETE -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${DOMAIN}/${i}/ | jq -r .detail)
          if [[ ! -z "$RESULT" ]]; then
            echo "$RESULT   $DOMAIN/$i"
          else
            echo "Deleted   $DOMAIN/$i"
          fi
        fi
      fi
    fi
  fi
done

curl -s -X POST -H "Accept: application/json" -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/logout/
echo "Completed! logging out"
