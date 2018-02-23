$ErrorActionPreference = “Stop”;
trap { $host.SetShouldExit(1) }

cd local-volume-release


$env:GOPATH=$PWD
$env:PATH="$PWD/bin;$env:PATH"

go install github.com/onsi/ginkgo/ginkgo

cd src/code.cloudfoundry.org/localdriver
ginkgo -r -keepGoing -p -trace -randomizeAllSpecs -progress --race

