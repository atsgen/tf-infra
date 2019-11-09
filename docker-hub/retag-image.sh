#!/bin/bash
#
# script to manage renaming of image tags within the same domain :tags from docker hub
# Maintainer: prabhjot@atsgen.com
#
# filter repo pattern that you do not want to touch
FILTER=''
 
# old tag of the image
OLD_TAG=''

# new tag with which image needs to be tagged
TAG=''
 
DOMAIN='atsgen'
 
# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

usage() {
  echo "$0   Usage: "
  echo "         -h  help"
  echo "         -o <TAG> old image tag eg. r5.1"
  echo "         -t <TAG> new image tag to be created eg. r5.1"
  echo "         -d <domain> domain eg. atsgen"
}

while getopts "h?o:t:d:n:f:" opt; do
    case "$opt" in
    h|\?)
        usage;
        exit 0
        ;;
    o)  OLD_TAG=$OPTARG
        ;;
    t)  TAG=$OPTARG
        ;;
    d)  DOMAIN=$OPTARG
        ;;
    f)  FILTER=$OPTARG
        ;;
    esac
done

if [[ -z "$OLD_TAG" || -z "$TAG" ]]; then
  echo "old image tag and new image tag are mandatory parameters"
  usage
  exit 1
fi

echo
echo "**************************************************************************"
echo "re-Tagging images with from Domain $DOMAIN/*:$OLD_TAG to $DOMAIN/*:$TAG"
echo "**************************************************************************"

if [[ $OLD_TAG == $TAG ]]; then
   echo "Nothing to do, New Tag is same as Old Tag"
   exit 0
fi

source $(dirname $0)/common/login_token.sh
source $(dirname $0)/common/functions.sh

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

# get list of repositories for domain
REPO_LIST=$(curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${DOMAIN}/?page_size=1000 | jq -r '.results|.[]|.name')
 
for i in ${REPO_LIST}
do
  if [[ -z "$FILTER" || $i != *$FILTER* ]]; then
    PTOKEN="$(curl -sSL -u ${UNAME}:${UPASS} "https://auth.docker.io/token?service=registry.docker.io&scope=repository:${DOMAIN}/${i}:pull,push" | jq -r .token)"
    MANIFEST=$(curl -s -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -H "Authorization: Bearer ${PTOKEN}" -X GET https://registry.hub.docker.com/v2/${DOMAIN}/${i}/manifests/${OLD_TAG})
    VERSION=$(echo $MANIFEST | jq -r .schemaVersion)
    if [[ ! -z "${VERSION}" && "null" != "$VERSION" ]]; then
      echo "Got manifest for ${DOMAIN}/${i}:${OLD_TAG}"
      curl -s -X PUT -H "Content-Type: application/vnd.docker.distribution.manifest.v2+json" -H "Authorization: Bearer ${PTOKEN}" -d "${MANIFEST}" https://registry.hub.docker.com/v2/${DOMAIN}/${i}/manifests/${TAG}
    else
      echo "Tag notfound for ${DOMAIN}/${i}:${OLD_TAG}"
    fi
  fi
done

curl -s -X POST -H "Accept: application/json" -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/logout/
echo "Completed! logging out"
