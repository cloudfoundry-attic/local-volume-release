#!/bin/bash

set -e -x

pushd ~/workspace/cf-release
    ./scripts/generate-bosh-lite-dev-manifest
popd

pushd ~/workspace/diego-release
    USE_VOLDRIVER=true ./scripts/generate-bosh-lite-manifests
popd

pushd ~/workspace/local-volume-release
    ./scripts/generate-bosh-lite-manifest.sh
popd

bosh -n -d ~/workspace/cf-release/bosh-lite/deployments/cf.yml deploy

bosh -n -d ~/workspace/diego-release/bosh-lite/deployments/diego.yml deploy

bosh -n -d ~/workspace/local-volume-release/manifests/bosh-lite/broker.yml deploy
