#!/bin/bash
set -e

usage () {
    echo "Usage: generate-bosh-lite-manifest.sh director-uuid bosh-target bosh-username bosh-password localbroker-username localbroker-password"
    echo " * default"
    exit 1
}

templates=$(dirname $0)/../templates

if [[ "$#" -le 3 ]]
    then
        usage
fi


cat > ${PWD}/director-uuid.yml << EOF
---
director_uuid: $1
EOF

cat > ${PWD}/localbroker-creds.yml << EOF
---
jobs:
- name: pats-broker
  properties:
    localbroker:
      username: $5
      password: $6
EOF


$templates/generate_manifest.sh bosh-lite \
    /dev/null \
    ${PWD}/director-uuid.yml \
    ${2} \
    ${3} \
    ${4} \
    ${PWD}/localbroker-creds.yml

rm ${PWD}/director-uuid.yml
rm ${PWD}/cell-ip.yml
rm ${PWD}/localbroker-creds.yml

