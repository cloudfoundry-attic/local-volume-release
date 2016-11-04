#!/bin/bash

set -e -x

pushd ~/workspace/cf-release
    ./scripts/generate-bosh-lite-dev-manifest
    sed -i -e 's/default_to_diego_backend: false/default_to_diego_backend: true/g' bosh-lite/deployments/cf.yml
popd

pushd ~/workspace/diego-release
    ./scripts/generate-bosh-lite-manifests
popd

pushd ~/workspace/local-volume-release
    ./templates/generate_runtime_config.sh lite admin admin
    bosh -n update runtime-config ./runtime-config.yml

    bosh -n -d ~/workspace/cf-release/bosh-lite/deployments/cf.yml deploy

    bosh -n -d ~/workspace/diego-release/bosh-lite/deployments/diego.yml deploy

    ./scripts/generate-bosh-lite-manifest.sh $(bosh status --uuid) https://192.168.50.4:25555 admin admin admin admin

    bosh -n -d ~/workspace/local-volume-release/localvolume-boshlite-manifest.yml deploy
popd
