$ErrorActionPreference = “Stop”;
trap { $host.SetShouldExit(1) }

cd local-volume-release

$env:GOPATH=$PWD
$env:PATH="$PWD/bin;$env:PATH"

go install github.com/onsi/ginkgo/ginkgo

go build -o "./localdriver" "src/code.cloudfoundry.org/localdriver/cmd/localdriver/main.go"

go get -t code.cloudfoundry.org/volume_driver_cert

$env:FIXTURE_FILENAME="$PWD/scripts/fixtures/certification_tcp.json"

mkdir voldriver_plugins
mkdir mountdir
Start-Process -NoNewWindow ./localdriver "-listenAddr=0.0.0.0:9776 -transport=tcp -mountDir=mountdir -driversPath=voldriver_plugins"

cd src/code.cloudfoundry.org/volume_driver_cert
ginkgo

Stop-Process -Name "localdriver"
