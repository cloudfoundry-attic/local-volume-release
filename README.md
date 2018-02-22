# local volume release
This is a bosh release that packages a [localdriver](https://github.com/cloudfoundry-incubator/localdriver) and a [localbroker](https://github.com/cloudfoundry-incubator/localbroker) for consumption by a Cloud Foundry deployment.

local-volume-release is a "dummy" volume release that exposes ephemeral storage on the diego cell as a volume in cloud-foundry.  As such it is really only suitable for experimenting with apps that require volumes.  The easiest way to consume local-volume-release is to install [PCFDev](https://docs.pivotal.io/pcf-dev/) which comes with local-volume-release already included.

The instructions below will help you should you desire to install local-volume-release into your own Cloud Foundry deployment.

# Deploying local-volume-release with Cloud Foundry

## Pre-requisites

1. Install Cloud Foundry, or start from an existing CF deployment.  If you are starting from scratch, the article [Overview of Deploying Cloud Foundry](https://docs.cloudfoundry.org/deploying/index.html) provides detailed instructions.

1. Install [GO](https://golang.org/dl/):

    ```bash
    mkdir ~/workspace ~/go
    cd ~/workspace
    wget https://storage.googleapis.com/golang/go1.9.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.9.linux-amd64.tar.gz
    echo 'export GOPATH=$HOME/go' >> ~/.bashrc
    echo 'export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin' >> ~/.bashrc
    exec $SHELL
    ```

1. Install [direnv](https://github.com/direnv/direnv#from-source):

    ```bash
    mkdir -p $GOPATH/src/github.com/direnv
    git clone https://github.com/direnv/direnv.git $GOPATH/src/github.com/direnv/direnv
    pushd $GOPATH/src/github.com/direnv/direnv
        make
        sudo make install
    popd
    echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
    exec $SHELL
    ```

## Create and Upload this Release

1. Check out local-volume-release (master branch) from git:

    ```bash
    cd ~/workspace
    git clone https://github.com/cloudfoundry/local-volume-release.git
    cd ~/workspace/local-volume-release
    direnv allow
    git checkout master
    ./scripts/update
    bosh -n create-release --force 
    bosh -n upload-release
    ```

## Redeploy Cloud Foundry with local-volume-release enabled

1. You should have it already after deploying Cloud Foundry, but if not clone the cf-deployment repository from git:

    ```bash
    $ cd ~/workspace
    $ git clone https://github.com/cloudfoundry/cf-deployment.git
    $ cd ~/workspace/cf-deployment
    ```

2. Now redeploy your cf-deployment while including the local-volume-release ops file:
    ```bash
    $ bosh -e my-env -d cf deploy cf.yml \
    -v deployment-vars.yml \ 
    -o ../efs-volume-release/operations/enable-local-volume-service.yml
    ```
    
**Note:** the above command is an example, but your deployment command should match the one you used to deploy Cloud Foundry initially, with the addition of a `-o ../local-volume-release/operations/enable-local-volume-service.yml` option.

Your CF deployment will now have a running service broker and volume drivers, ready to create and mount local "volumes".  Unless you have explicitly defined a variable for your service broker password, BOSH will generate one for you.  
If you let BOSH generate the efsbroker password for you, you can find the password for use in broker registration via the `bosh interpolate` command:
 
```
bosh int deployment-vars.yml --path /local-broker-password
```

## Register local-broker

```bash
cf create-service-broker localbroker admin <PASSWORD> http://local-broker.YOUR.DOMAIN.com
cf enable-service-access local-volume
```

## Deploy pora and test volume services

```bash
cf create-service local-volume free-local-disk local-volume-instance
cf push pora -f ./assets/pora/manifest.yml -p ./assets/pora/ --no-start
cf bind-service pora local-volume-instance
cf start pora
```
> #### Bind Parameters
> * **mount:** By default, volumes are mounted into the application container in an arbitrarily named folder under /var/vcap/data.  If you prefer to mount your directory to some specific path where your application expects it, you can control the container mount path by specifying the `mount` option.  The resulting bind command would look something like 
> ``` cf bind-service pora local-volume-instance -c '{"mount":"/var/foo"}'```

## Test the app to make sure that it can access your volume
* to check if the app is running, `curl http://pora.YOUR.DOMAIN.com` should return the instance index for your app
* to check if the app can access the shared volume `curl http://pora.YOUR.DOMAIN.com/write` writes a file to the share and then reads it back out again.

# Troubleshooting
If you have trouble getting this release to operate properly, try consulting the [Volume Services Troubleshooting Page](https://github.com/cloudfoundry-incubator/volman/blob/master/TROUBLESHOOTING.md)
