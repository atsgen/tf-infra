# tf-infra-tools
Tungsten Fabric Infrastructure tools repository, holds scripts/tools for various infrastructure components

### docker-hub
Utilites/Scripts under docker-hub directory expects system to have curl and jq installed.

*For Ubuntu - sudo apt-get install -y curl jq*

* *delete-image-tag.sh* - Script to manage deletion of deprecated tags for all the repositories listed under tungstenfabric namespace/domain. This uses dockerhub user authentication to trigger deletes.
  * One can trigger delete of tag r5.0 for example using ./delete-image-tag.sh -t r5.0
  * detailed options are available under -h help option
