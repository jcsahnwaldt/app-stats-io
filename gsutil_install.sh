#!/bin/bash -e

# `gsutil -m cp` works with Python 3.7, but not with 3.8
# See https://github.com/GoogleCloudPlatform/gsutil/issues/961
# PYTHON=python3
PYTHON=/usr/local/opt/python@3.7/bin/python3

cd "$(dirname "$0")"
$PYTHON -m venv --prompt gsutil venv
source venv/bin/activate
pip install --upgrade pip wheel
pip install --upgrade gsutil
test ! -f .boto && gsutil config -b -o .boto
