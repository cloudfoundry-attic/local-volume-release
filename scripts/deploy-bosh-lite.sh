#!/bin/bash

set -e -x

pushd ~/workspace/cf-release
    ./scripts/generate-bosh-lite-dev-manifest
    sed -i -e 's/default_to_diego_backend: false/default_to_diego_backend: true/g' bosh-lite/deployments/cf.yml
popd

pushd ~/workspace/diego-release
    USE_VOLDRIVER=true ./scripts/generate-bosh-lite-manifests
popd

bosh -n -d ~/workspace/cf-release/bosh-lite/deployments/cf.yml deploy

bosh -n -d ~/workspace/diego-release/bosh-lite/deployments/diego.yml deploy

pushd ~/workspace/local-volume-release
    ./scripts/generate-bosh-lite-manifest.sh
popd

bosh -n -d ~/workspace/local-volume-release/manifests/bosh-lite/broker.yml deploy
