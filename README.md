# local volume release
This is a bosh release that packages a [localdriver](https://github.com/cloudfoundry-incubator/localdriver) and a [localbroker](https://github.com/cloudfoundry-incubator/localbroker) for consumption by a volman-enabled Cloud Foundry deployment.

# Deploying to Bosh-Lite

## Pre-requisites

1. Install and start [BOSH-Lite](https://github.com/cloudfoundry/bosh-lite), following its [README](https://github.com/cloudfoundry/bosh-lite/blob/master/README.md).  For garden-linux to function properly in the Diego deployment, we recommend using version 9000.69.0 or later of the BOSH-Lite Vagrant box image.

2. Install spiff according to its [README](https://github.com/cloudfoundry-incubator/spiff). spiff is a tool for generating BOSH manifests that is required in some of the scripts used below.

## Create and Upload Releases

3. Upload the latest version of the Warden BOSH-Lite stemcell directly to BOSH-Lite:

`bosh upload stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent`

Alternately, download the stemcell locally first and then upload it to BOSH-Lite:

`curl -L -o bosh-lite-stemcell-latest.tgz https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent
bosh upload stemcell bosh-lite-stemcell-latest.tgz`

4. Upload the latest garden-linux-release OR garden-runc-release:
   
```
bosh upload release https://bosh.io/d/github.com/cloudfoundry-incubator/garden-linux-release

# if you specified [-g] when you generated your manifest:
# bosh upload release https://bosh.io/d/github.com/cloudfoundry-incubator/garden-runc-release
```

5. Upload the latest etcd-release:

`bosh upload release https://bosh.io/d/github.com/cloudfoundry-incubator/etcd-release`

6. Upload the latest cflinuxfs2-rootfs-release:

`bosh upload release https://bosh.io/d/github.com/cloudfoundry/cflinuxfs2-rootfs-release`

7. Check out cf-release (release-candidate branch or tagged release) from git:

```
cd ~/workspace
git clone https://github.com/cloudfoundry/cf-release.git
cd ~/workspace/cf-release
git checkout release-candidate # do not push to release-candidate
./scripts/update
bosh -n create release --force && bosh -n upload release
```

8. Check out diego-release (master branch or tagged release) from git:

```
cd ~/workspace
git clone https://github.com/cloudfoundry/diego-release.git
cd ~/workspace/diego-release
git checkout develcd ../loc op 
./scripts/update
bosh -n create release --force && bosh -n upload release
```

9. Check out local-volume-release (master branch) from git:

```
cd ~/workspace
git clone https://github.com/cloudfoundry-incubator/local-volume-release.git
cd ~/workspace/local-volume-release
git checkout mastercd ../diego  
./scripts/update
bosh -n create release --force && bosh -n upload release
```

## Generate Manifests and Deploy

10. Execute the following script to generate all manifests and deploy:-

```
cd ~/workspace/local-volume-release
./scripts/deploy-bosh-lite.sh
```

## Register local-broker

```bash
# optionaly delete previous broker:
cf delete-service-broker localbroker

cf create-service-broker localbroker admin admin http://localbroker.bosh-lite.com
cf enable-service-access local-volume
```

## Deploy pora and test volume services

```bash
cf create-service local-volume free-local-disk local-volume-instance

cf push pora -f ./assets/pora/manifest.yml --no-start

cf bind-service pora local-volume-instance

cf start pora
```

The localbroker, as it stands, keeps all state in memory. This means that bosh deploys will leave the broker out of sync with cc. To fix this:
```bash
cf purge-service-instance local-volume-instance
cf create-service local-volume free-local-disk local-volume-instance
```
