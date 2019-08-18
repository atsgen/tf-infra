# tf-infra-tools
Tungsten Fabric Infrastructure tools repository, holds scripts/tools for various infrastructure components

### docker-hub
Utilites/Scripts under docker-hub directory expects system to have curl and jq installed.

*For Ubuntu - sudo apt-get install -y curl jq*

* *delete-image-tag.sh* - Script to manage deletion of deprecated tags for all the repositories listed under tungstenfabric namespace/domain. This uses dockerhub user authentication to trigger deletes.
  * One can trigger delete of tag r5.0 for example using ./delete-image-tag.sh -t r5.0
  * detailed options are available under -h help option
* *retag-image.sh* - Script to manage retagging for all repositories under tungstenfabric domain. This uses docker hub user authentication to trigger retagging.
  * Retagging from 'R5.1-2019-07-24' to 'r5.1.1' for example can be triggered by ./retag-image.sh -o R5.1-2019-07-24 -t r5.1.1 
  * detailed options are available under the -h help option

### release-tools
Utilites/Scripts under release-tools are available to assit with building release images, expected to work only on images available locally

* *docker-inspect-labels.sh* - Script to validate that community build does not contain juniper/contrail domain and vendor name.
  * run without any argument checks of label with juniper and reports any image that contains any such label
  * detailed options are available under -h help option
