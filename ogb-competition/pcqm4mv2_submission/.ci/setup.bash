#!/usr/bin/env bash
# Copyright (c) 2022 Graphcore Ltd. All rights reserved.

###
# Here run your prerequisites before running the tests
###

# cd to app root directory
cd "$(dirname "$0")"/..

# System packages
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install wget

# Upgrade pip
python3 -m pip install --upgrade pip

# Python packages
python3 -m pip install -r requirements.txt
python3 -m pip install -r requirements-dev.txt

# Get dataset splits
wget https://graphcore-ogblsc-pcqm4mv2.s3.us-west-1.amazonaws.com/pcqm4mv2-cross_val_splits.tar.gz
tar xvzf pcqm4mv2-cross_val_splits.tar.gz

echo "Python version: $(python3 --version)"
echo "Pip version: $(python3 -m pip --version)"
