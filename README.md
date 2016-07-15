# local volume release
This is a bosh release that packages a [localdriver](https://github.com/cloudfoundry-incubator/localdriver) and a [localbroker](https://github.com/cloudfoundry-incubator/localbroker) for consumption by a volman-enabled Cloud Foundry deployment.

# deploying to bosh-lite

Beginning from a deployed, Diego-backed Cloud Foundry,

To deploy a localbroker, to bosh-lite:
```bash
scripts/generate-bosh-lite-manifest.sh
bosh create release --force && bosh upload release && bosh -d manifests/bosh-lite/broker.yml deploy
```

Then, to register the service broker and create a service instance:
```bash
# optionaly delete previous broker:
cf delete-service-broker localbroker
cf create-service-broker localbroker admin admin http://localbroker.bosh-lite.com
cf enable-service-access local-volume
cf create-service local-volume free-local-disk local-volume-instance
cf bind-service pora local-volume-instance
```

The localbroker, as it stands, keeps all state in memory. This means that bosh deploys will leave the broker out of sync with cc. To fix this:
```bash
cf purge-service-instance local-volume-instance
cf create-service local-volume free-local-disk local-volume-instance
```
