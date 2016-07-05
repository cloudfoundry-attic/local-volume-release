#!/bin/bash

cd `dirname $0`

pkill -f localdriver

mkdir -p ~/voldriver_plugins
rm ~/voldriver_plugins/localdriver.*

mkdir -p ../mountdir

driversPath=$HOME/voldriver_plugins
~/localdriver -listenAddr="0.0.0.0:9776" -transport="tcp" -mountDir="../mountdir" -driversPath="${driversPath}" &
