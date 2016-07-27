#!/bin/bash
#generate_manifest.sh



# this is a hack to create a backchannel from the broker to the cell.
# this is why this is not a production release/broker pair.
# do not backchannel to real, shared, and/or dfs volume-drivers.
get_cell_ip ()
{
# get the full diego deployment, it should have IPs in it
taskID=$(curl -I -s -k "https://${5}:${6}@${4}/deployments/cf-warden-diego/vms?format=full" | grep tasks | awk -F "/" '{print $NF}' | tr -d "\r")
# but it redirects to the wrong URL, so fix that and get the task
taskIP=$(curl I -s -k "https://${5}:${6}@${4}/tasks/${taskID}")
# but that's got an asynchronous result endpoint to poll, so wait
sleep 5
# finally get the task result and rip the cell IP out of its json
cellIP=$(curl -s -k "https://${5}:${6}@${4}/tasks/${taskID}/output?type=result" | jq -r 'select(.job_name | contains("cell_z1")) | .ips[]')
}

print_cell_ip_stub ()
{
get_cell_ip
cat > ${PWD}/cell-ip.yml << EOF
---
properties:
  localbroker:
    localdriver-url: http://${cellIP}:8089
EOF
}


usage () {
    echo "Usage: generate_manifest.sh bosh-lite|aws cf-manifest director-stub bosh_target bosh_username bosh_password"
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
    print_cell_ip_stub

    MANIFEST_NAME=localvolume-aws-manifest

    spiff merge ${templates}/localvolume-manifest-aws.yml \
    $2 \
    $3 \
    ${PWD}/cell-ip.yml \
    ${templates}/stubs/toplevel-manifest-overrides.yml \
    > $PWD/$MANIFEST_NAME.yml
fi

echo manifest written to $PWD/$MANIFEST_NAME.yml
