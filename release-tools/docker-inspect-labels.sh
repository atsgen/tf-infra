#!/bin/bash
#
# NOTE: Validates labels assuming images available locally
#       uses docker utility
#
# script to validate labels in docker images
#
# Maintainer: prabhjot@atsgen.com
#

# filter repo pattern that you do not want to look into
FILTER=''

DOMAIN=':6666'

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

EXCEPT=''

INCLUDE=''

usage() {
  echo "$0   Usage: "
  echo "         -h  help"
  echo "         -t <TAG> image tag to be validated"
  echo "         -d <domain> domain for which images need to be validated"
  echo "         -f <filter> images to skip"
  echo "         -e <ignore_case_except_match_str> Error if label exist"
  echo "         -i <ignore_case_match_str> Error if label does not exist"
}

while getopts "h?t:d:e:i:f:" opt; do
    case "$opt" in
    h|\?)
        usage
        exit 0
        ;;
    t)  TAG=$OPTARG
        ;;
    d)  DOMAIN=$OPTARG
        ;;
    e)  EXCEPT=$OPTARG
        ;;
    i)  INCLUDE=$OPTARG
        ;;
    f)  FILTER=$OPTARG
        ;;
    esac
done

if [[ -z "$EXCEPT" && -z "$INCLUDE" ]]; then
  echo "assuming except_match_str juniper"
  EXCEPT="juniper"
fi


STR="docker images | grep -v REPOSITORY"
if [[ ! -z "$DOMAIN" ]]; then
  STR="$STR | grep $DOMAIN"
fi
if [[ ! -z "$TAG" ]]; then
  STR="$STR | grep $TAG"
fi

if [[ ! -z "$FILTER" ]]; then
  STR="$STR | grep -v $FILTER"
fi

echo $STR

# build list of container images
RES=( $(eval $STR | awk '{split($0, a, " "); print a[1]":"a[2]}') )
for element in "${RES[@]}"
do
  RESULT=""
  if [[ ! -z "$EXCEPT" ]]; then
    RESULT=`docker inspect -f '{{ range $k, $v := .ContainerConfig.Labels -}} {{ $k }}={{ $v }} {{ end -}}' ${element} | grep -i "$EXCEPT"` 
  fi

  if [[ ! -z "$INCLUDE" && -z "$RESULT" ]]; then
    RESULT=`docker inspect -f '{{ range $k, $v := .ContainerConfig.Labels -}} {{ $k }}={{ $v }} {{ end -}}' ${element} | grep -v -i "$INCLUDE"` 
  fi
  if [[ ! -z "$RESULT" ]]; then
    echo "${element} has tags $RESULT"
    echo ""
  fi
done
