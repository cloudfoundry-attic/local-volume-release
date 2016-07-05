#!/bin/bash

cd `dirname $0`
cd ..

go build -o "$HOME/localdriver" "src/github.com/cloudfoundry-incubator/localdriver/cmd/localdriver/main.go"

#=======================================================================================================================
# localdriver runs in 4 different modes to test the 4 different transports we support.  This script tests all 4
#=======================================================================================================================

# UNIX SOCKET TESTS
export FIXTURE_FILENAME=$PWD/scripts/fixtures/certification_unix.json
/bin/bash scripts/startdriver_unix.sh
pushd src/github.com/cloudfoundry-incubator/volume_driver_cert
    ginkgo
popd
/bin/bash scripts/stopdriver.sh

# TCP TESTS
export FIXTURE_FILENAME=$PWD/scripts/fixtures/certification_tcp.json
/bin/bash scripts/startdriver_tcp.sh
pushd src/github.com/cloudfoundry-incubator/volume_driver_cert
    ginkgo
popd
/bin/bash scripts/stopdriver.sh

# JSON SPEC TESTS
export FIXTURE_FILENAME=$PWD/scripts/fixtures/certification_json.json
/bin/bash scripts/startdriver_json.sh
pushd src/github.com/cloudfoundry-incubator/volume_driver_cert
    ginkgo
popd
/bin/bash scripts/stopdriver.sh

# JSON TLS SPEC TESTS
export FIXTURE_FILENAME=$PWD/scripts/fixtures/certification_json.json
/bin/bash scripts/startdriver_json_tls.sh
pushd src/github.com/cloudfoundry-incubator/volume_driver_cert
    ginkgo
popd
/bin/bash scripts/stopdriver.sh

rm $HOME/localdriver
