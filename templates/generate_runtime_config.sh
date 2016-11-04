#!/bin/bash

###### find the release version of the local-volume bosh release
bosh --non-interactive target ${1}
bosh login ${2} ${3}
version=`bosh releases | awk '{if($2 == "local-volume") sect=1; else if($2 != "|") sect=0; gsub(/\*/, ""); if(sect==1) if($2=="|") outv=$3; else outv=$4;} END{print outv}'`
if [[ "$version" == "|" ]] || [[ "$version" == "" ]]; then
      echo "local-volume release appears not to be uploaded to bosh"
      exit 1
fi
cat > ${PWD}/runtime-config.yml << EOF
---
releases:
- name: local-volume
  version: "$version"
addons:
- name: voldrivers
  include:
    deployments: [cf-warden-diego]
    jobs: [{name: rep, release: diego}]
  jobs:
  - name: localdriver
    release: local-volume
    properties: {}
EOF
######

