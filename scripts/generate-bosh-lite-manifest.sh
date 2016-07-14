#!/bin/bash
set -e

release_dir=$(cd $(dirname $0)/.. && pwd)

# this is a hack to create a backchannel from the broker to the cell.
# this is why this is not a production release/broker pair.
# do not backchannel to real, shared, and/or dfs volume-drivers.
get_cell_ip ()
{
# get the full diego deployment, it should have IPs in it
taskID=$(curl -I -s -k 'https://admin:admin@192.168.50.4:25555/deployments/cf-warden-diego/vms?format=full' | grep tasks | awk -F "/" '{print $NF}' | tr -d "\r")
# but it redirects to the wrong URL, so fix that and get the task
taskIP=$(curl I -s -k "https://admin:admin@192.168.50.4:25555/tasks/${taskID}")
# but that's got an asynchronous result endpoint to poll, so wait
sleep 1
# finally get the task result and rip the cell IP out of its json
cellIP=$(curl -s -k "https://admin:admin@192.168.50.4:25555/tasks/${taskID}/output?type=result" | jq -r 'select(.job_name | contains("cell_z1")) | .ips[]')
}

print_director_stub ()
{
cat > ${release_dir}/mangen/stubs/generated/director-uuid.yml << EOF
---
director_uuid: $(bosh -t lite status --uuid)
EOF
}

print_cell_ip_stub ()
{
get_cell_ip
cat > ${release_dir}/mangen/stubs/generated/cell-ip.yml << EOF
---
properties:
  localbroker:
    localdriver-url: http://${cellIP}:8089
EOF
}

print_director_stub
print_cell_ip_stub
spiff merge \
  ${release_dir}/mangen/templates/broker.yml \
  ${release_dir}/mangen/stubs/generated/director-uuid.yml \
  ${release_dir}/mangen/stubs/generated/cell-ip.yml \
  > ${release_dir}/manifests/bosh-lite/broker.yml


echo "Local Broker Manifest at ${release_dir}/manifests/bosh-lite/broker.yml"
