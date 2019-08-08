cript to manage renaming of image tags within the same domain :tags from docker hub
# Maintainer: prabhjot@atsgen.com
#
# filter repo pattern that you do not want to touch
FILTER='developer-sandbox'
 
# old tag of the image
OLD_TAG='second'

# new tag with which image needs to be tagged
TAG='test'
 
DOMAIN='tungstenfabric'
 
# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

UNAME=''
UPASS=''

while getopts "h?o:t:d:n:f:" opt; do
    case "$opt" in
    h|\?)
        echo "$0   Usage: "
        echo "         -h  help"
        echo "         -o <TAG> old image tag eg. r5.1"
        echo "         -t <TAG> new image tag to be created eg. r5.1"
        echo "         -d <domain> domain eg. tungstenfabric"
        echo "         -f <filter> repositories to skip"
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

echo
echo "**************************************************************************"
echo "re-Tagging images with from Domain $DOMAIN/*:$OLD_TAG to $DOMAIN/*:$TAG"
echo "**************************************************************************"
echo
echo
echo "Please use your Docker Hub ID to Authenticate"
echo "*********************************************"
echo -n "Username: " 
read UNAME
echo -n "Password: "
read -s UPASS
echo

TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${UNAME}'", "password": "'${UPASS}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token)

if [[ -z "$TOKEN" || "null" == "$TOKEN" ]]; then
  echo "failed to authenticate for user $UNAME"
  exit 1
fi

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

# get list of repositories for tungstenfabric domain
REPO_LIST=$(curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${DOMAIN}/?page_size=1000 | jq -r '.results|.[]|.name')
 
for i in ${REPO_LIST}
do
  if [[ $i != *$FILTER* ]]; then
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
