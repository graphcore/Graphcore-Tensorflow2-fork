#!/usr/bin/env bash
# Copyright (c) 2022 Graphcore Ltd. All rights reserved.

###
# Here run your tests
# JUnit XML files with the patten `*report.xml` will be published as a test report
###

# cd to app root directory and add `utils/examples_tests` to PYTHONPATH
cd "$(dirname "$0")"/..
export PYTHONPATH=$(cd ../../../utils; pwd):$PYTHONPATH

# Run tests
ec=0
for i in `ls tests/test_*`; do python3 -m pytest -n 5 --forked --junitxml=${i}_report.xml --rootdir=../../.. $i || ((ec++)); done
python3 -m pytest --junitxml=serial_report.xml --rootdir=../../.. tests_serial || ((ec++))
exit $ec
