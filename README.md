# local volume release
This is a bosh release that packages a [localdriver](https://github.com/cloudfoundry-incubator/localdriver) and a [localbroker](https://github.com/cloudfoundry-incubator/localbroker) for consumption by a volman-enabled Cloud Foundry deployment.

# deploying to bosh-lite

Beginning from a deployed, Diego-backed Cloud Foundry,

To deploy a localbroker, first add your bosh-lite director-uuid to `manifest/bosh-lite/localbroker.yml`, then run the following:
```bash
bosh create release --force && bosh upload release && bosh -d manifest/bosh-lite/localbroker.yml deploy
```

Then, to register the service broker:
```bash
cf create-service-broker localbroker admin admin http://localbroker.bosh-lite.com
cf enable-service-access local-volume
```
