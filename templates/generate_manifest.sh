#!/bin/bash
#generate_manifest.sh



usage () {
    echo "Usage: generate_manifest.sh bosh-lite|aws cf-manifest director-stub localbroker-creds-stub cell-ip-stub"
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
    echo "Use ../scripts/generate-bosh-lite-manifest.sh"
    exit 1
fi

if [ "$1" == "aws" ]
  then
    MANIFEST_NAME=localvolume-aws-manifest

    spiff merge ${templates}/localvolume-manifest-aws.yml \
    $2 \
    $3 \
    $4 \
    $5 \
    ${templates}/stubs/toplevel-manifest-overrides.yml \
    > $PWD/$MANIFEST_NAME.yml
fi

echo manifest written to $PWD/$MANIFEST_NAME.yml
