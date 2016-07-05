#!/bin/bash

cd `dirname $0`

pkill -f localdriver

mkdir -p ~/voldriver_plugins
rm ~/voldriver_plugins/localdriver.*

mkdir -p ../mountdir

driversPath=$HOME/voldriver_plugins
~/localdriver -listenAddr="127.0.0.1:9876" -transport="tcp-json" -mountDir="../mountdir" -driversPath="${driversPath}" -requireSSL=true -caFile="$PWD/certs/localdriver_ca.crt" -certFile="$PWD/certs/localdriver_server.crt" -keyFile="$PWD/certs/localdriver_server.key" -clientCertFile="$PWD/certs/localdriver_client.crt" -clientKeyFile="$PWD/certs/localdriver_client.key" -insecureSkipVerify=true &
