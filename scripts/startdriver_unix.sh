#!/bin/bash

set -x

cd `dirname $0`

pkill -f localdriver

mkdir -p ~/voldriver_plugins
rm ~/voldriver_plugins/localdriver.*

mkdir -p ../mountdir

# temporarily create a sock file in order to find an absolute path for it
touch ~/voldriver_plugins/localdriver.sock
listenAddr=$HOME/voldriver_plugins/localdriver.sock
rm ~/voldriver_plugins/localdriver.sock

~/localdriver -listenAddr="${listenAddr}" -transport="unix" -mountDir="../mountdir" &
