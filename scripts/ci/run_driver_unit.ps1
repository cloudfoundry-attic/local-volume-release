﻿$ErrorActionPreference = “Stop”;
trap { $host.SetShouldExit(1) }

cd local-volume-release

function CheckLastExitCode {
    param ([int[]]$SuccessCodes = @(0), [scriptblock]$CleanupScript=$null)

    if ($SuccessCodes -notcontains $LastExitCode) {
        if ($CleanupScript) {
            "Executing cleanup script: $CleanupScript"
            &$CleanupScript
        }
        $msg = @"
EXE RETURNED EXIT CODE $LastExitCode
CALLSTACK:$(Get-PSCallStack | Out-String)
"@
        throw $msg
    }
}

$env:GOPATH=$PWD
$env:PATH="$PWD/bin;$env:PATH"

go install github.com/onsi/ginkgo/ginkgo

cd src/code.cloudfoundry.org/localdriver
ginkgo -r -keepGoing -p -trace -randomizeAllSpecs -progress --race

CheckLastExitCode
