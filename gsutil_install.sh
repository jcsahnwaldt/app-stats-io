#!/bin/bash -e

cd "$(dirname "$0")"
python3 -m venv --prompt gsutil venv
source venv/bin/activate
pip install --upgrade pip wheel
pip install --upgrade gsutil
test ! -f .boto && gsutil config -b -o .boto
