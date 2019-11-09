#!/bin/bash
#
# script to list all the repos, or repos for a given tag in given domain
# Maintainer: prabhjot@atsgen.com
#
 
# new tag with which image needs to be tagged
TAG=''
 
DOMAIN='atsgen'
 
# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

usage() {
  echo "$0   Usage: "
  echo "         -h  help"
  echo "         -t <TAG> for which repos needs to be listed eg. r5.1"
  echo "         -d <domain> domain eg. atsgen"
}

while getopts "h?t:d:" opt; do
    case "$opt" in
    h|\?)
        usage;
        exit 0
        ;;
    t)  TAG=$OPTARG
        ;;
    d)  DOMAIN=$OPTARG
        ;;
    esac
done

source $(dirname $0)/common/login_token.sh
source $(dirname $0)/common/functions.sh

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

# get list of repositories for domain
get_repos
 
for i in ${REPO_LIST}
do
  if [[ ! -z "$TAG" ]]; then
    PTOKEN="$(curl -sSL -u ${UNAME}:${UPASS} "https://auth.docker.io/token?service=registry.docker.io&scope=repository:${DOMAIN}/${i}:pull,push" | jq -r .token)"
    MANIFEST=$(curl -s -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -H "Authorization: Bearer ${PTOKEN}" -X GET https://registry.hub.docker.com/v2/${DOMAIN}/${i}/manifests/${TAG})
    VERSION=$(echo $MANIFEST | jq -r .schemaVersion)
    if [[ ! -z "${VERSION}" && "null" != "$VERSION" ]]; then
      echo "${DOMAIN}/${i}"
    fi
  else
    echo "${DOMAIN}/${i}"
  fi
done

curl -s -X POST -H "Accept: application/json" -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/logout/ > /dev/null
