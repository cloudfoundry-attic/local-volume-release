#!/bin/bash
# vim: set ft=sh

set -e -x

scripts_path=./$(dirname $0)/..
eval $($scripts_path/get_paths.sh)

if [ "$(uname)" == "Darwin" ]; then
    export GOPATH=`greadlink -f ${scripts_path}/..`
else
    export GOPATH=`readlink -f ${scripts_path}/..`
fi
export PATH=$GOPATH/bin:$PATH

absolute_path() {
  (cd $1 && pwd)
}

base_path=$(absolute_path `dirname $0`)


source ${PERSI_ACCEPTANCE_DIR}/scripts/ci/utils.sh
check_param CF_USERNAME
check_param CF_PASSWORD
check_param CF_API_ENDPOINT
check_param APPS_DOMAIN
check_param APPLICATION_PATH
check_param NAME_PREFIX

if [ -z "$APPLICATION_PATH" ]; then
    echo "APPLICATION_PATH cannot be blank"
    exit 1
fi

go install -v code.cloudfoundry.org/persi-acceptance-tests/vendor/github.com/onsi/ginkgo/ginkgo

${scripts_path}/run-pats ${CF_USERNAME} ${CF_PASSWORD} ${CF_API_ENDPOINT} ${APPS_DOMAIN} ${base_path}/../../../${APPLICATION_PATH} ${NAME_PREFIX}
