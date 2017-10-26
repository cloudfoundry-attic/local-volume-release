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

if [ "$1" == "bosh-lite" ]
  then
    MANIFEST_NAME=localvolume-boshlite-manifest

    spiff merge ${templates}/localvolume-manifest-boshlite.yml \
    $3 \
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
    ${templates}/stubs/toplevel-manifest-overrides.yml \
    > $PWD/$MANIFEST_NAME.yml
fi

echo manifest written to $PWD/$MANIFEST_NAME.yml
