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
apt-get install -y libmetis-dev=5.1.0.dfsg-5

# Upgrade pip
python3 -m pip install --upgrade pip

# Python packages
python3 -m pip install -r requirements.txt

echo "Python version: $(python3 --version)"
echo "Pip version: $(python3 -m pip --version)"