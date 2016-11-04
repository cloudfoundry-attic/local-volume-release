#!/bin/bash

###### find the release version of the local-volume bosh release
bosh --non-interactive target ${1}
bosh login ${2} ${3}
version=`bosh releases | grep local-volume | awk '{gsub(/\*/, ""); print $4}'`
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

