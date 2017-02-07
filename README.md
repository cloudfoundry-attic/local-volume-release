# local volume release
This is a bosh release that packages a [localdriver](https://github.com/cloudfoundry-incubator/localdriver) and a [localbroker](https://github.com/cloudfoundry-incubator/localbroker) for consumption by a volman-enabled Cloud Foundry deployment.

# Deploying to Bosh-Lite

## Pre-requisites

1. Install and start [BOSH-Lite](https://github.com/cloudfoundry/bosh-lite), following its [README](https://github.com/cloudfoundry/bosh-lite/blob/master/README.md).  For garden-linux to function properly in the Diego deployment, we recommend using version 9000.69.0 or later of the BOSH-Lite Vagrant box image.

2. Install spiff according to its [README](https://github.com/cloudfoundry-incubator/spiff). spiff is a tool for generating BOSH manifests that is required in some of the scripts used below.

## Create and Upload Releases

1. Upload the latest version of the Warden BOSH-Lite stemcell directly to BOSH-Lite:

    `bosh upload stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent`

    Alternately, download the stemcell locally first and then upload it to BOSH-Lite:
    
    `curl -L -o bosh-lite-stemcell-latest.tgz https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent
    bosh upload stemcell bosh-lite-stemcell-latest.tgz`

2. Upload the latest garden-runc-release:
   
    ```bash
    bosh upload release https://bosh.io/d/github.com/cloudfoundry-incubator/garden-runc-release
    ```

3. Upload the latest etcd-release:

    `bosh upload release https://bosh.io/d/github.com/cloudfoundry-incubator/etcd-release`

4. Upload the latest cflinuxfs2-rootfs-release:

    `bosh upload release https://bosh.io/d/github.com/cloudfoundry/cflinuxfs2-rootfs-release`

5. Check out cf-release (release-candidate branch or tagged release) from git:

    ```bash
    cd ~/workspace
    git clone https://github.com/cloudfoundry/cf-release.git
    cd ~/workspace/cf-release
    git checkout release-candidate # do not push to release-candidate
    ./scripts/update
    bosh -n create release --force && bosh -n upload release
    ```

6. Check out diego-release (master branch or tagged release) from git:

    ```bash
    cd ~/workspace
    git clone https://github.com/cloudfoundry/diego-release.git
    cd ~/workspace/diego-release
    git checkout develop 
    ./scripts/update
    bosh -n create release --force && bosh -n upload release
    ```

7. Check out local-volume-release (master branch) from git:

    ```bash
    cd ~/workspace
    git clone https://github.com/cloudfoundry-incubator/local-volume-release.git
    cd ~/workspace/local-volume-release
    git checkout master
    ./scripts/update
    bosh -n create release --force && bosh -n upload release
    ```

## Generate Manifests and Deploy

8. Execute the following script to generate all manifests and deploy:-

    ```bash
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
    
    cf push pora -f ./assets/pora/manifest.yml -p ./assets/pora/ --no-start
    
    cf bind-service pora local-volume-instance
    
    cf start pora
    ```
> ####Bind Parameters####
> * **mount:** By default, volumes are mounted into the application container in an arbitrarily named folder under /var/vcap/data.  If you prefer to mount your directory to some specific path where your application expects it, you can control the container mount path by specifying the `mount` option.  The resulting bind command would look something like 
> ``` cf bind-service pora local-volume-instance -c '{"mount":"/my/path"}'```

# Troubleshooting
If you have trouble getting this release to operate properly, try consulting the [Volume Services Troubleshooting Page](https://github.com/cloudfoundry-incubator/volman/blob/master/TROUBLESHOOTING.md)
