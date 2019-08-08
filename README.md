# tf-infra-tools
Tungsten Fabric Infrastructure tools repository, holds scripts/tools for various infrastructure components

### docker-hub
Utilites/Scripts under docker-hub directory expects system to have curl and jq installed.

*For Ubuntu - sudo apt-get install -y curl jq*

* *delete-image-tag.sh* - Script to manage deletion of deprecated tags for all the repositories listed under tungstenfabric namespace/domain. This uses dockerhub user authentication to trigger deletes.
  * One can trigger delete of tag r5.0 for example using ./delete-image-tag.sh -t r5.0
  * detailed options are available under -h help option
* *rename-image-tag.sh* - Script to manage renaming of tags for all the repositories within the same domain. This also uses dockerhub user authentication to trigger renaming.
  * Renaming of tag 'old_tag' to 'test' in domain 'tungstenfabric' for example can be triggered by ./rename-image-tag.sh -o old_tag -t test -d tungstenfabric
  * detailed options are available under -h help option

