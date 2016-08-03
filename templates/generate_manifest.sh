#!/bin/bash
#generate_manifest.sh



usage () {
    echo "Usage: generate_manifest.sh bosh-lite|aws cf-manifest director-stub bosh-target bosh-username bosh-password localbroker-props-stub"
    echo " * default"
    exit 1
}

templates=$(dirname $0)

if [[  "$1" != "bosh-lite" && "$1" != "aws" || -z $3 ]]
  then
    usage
fi

###### find the cell IP of the localdriver
bosh --non-interactive target ${4}
bosh login ${5} ${6}
cellIP=`bosh vms | grep cell_z1 | awk '{print $11}'`
if [[ "$cellIP" == "|" ]] || [[ "$cellIP" == "" ]]; then
    echo "Check your diego deployment as no Cell IP could be determined."
    exit 1
fi
cat > ${PWD}/cell-ip.yml << EOF
---
properties:
  localbroker:
    localdriver-url: http://${cellIP}:9089
EOF
######

if [ "$1" == "bosh-lite" ]
  then
    MANIFEST_NAME=localvolume-boshlite-manifest

    spiff merge ${templates}/localvolume-manifest-boshlite.yml \
    $3 \
    ${PWD}/cell-ip.yml \
    $7 \
    > ${PWD}/$MANIFEST_NAME.yml
fi

if [ "$1" == "aws" ]
  then
    MANIFEST_NAME=localvolume-aws-manifest

    spiff merge ${templates}/localvolume-manifest-aws.yml \
    $2 \
    $3 \
    $7 \
    ${PWD}/cell-ip.yml \
    ${templates}/stubs/toplevel-manifest-overrides.yml \
    > $PWD/$MANIFEST_NAME.yml
fi

echo manifest written to $PWD/$MANIFEST_NAME.yml
