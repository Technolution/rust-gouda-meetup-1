#!/bin/bash

# This script installs the minimum dependencies to get the rustup,
# cargo, xargo and bobbin installed and running

apt update
apt install -y curl bzip2 dfu-util git gcc make

# you could install the 'build-essential' package if you expect
# to do more development that uses native C libraries
