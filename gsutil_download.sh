#!/bin/bash -e

cd "$(dirname "$0")"
source venv/bin/activate
source config.rb
BOTO_CONFIG=.boto gsutil -m cp -r gs://$GOOGLE_BUCKET/* "$GOOGLE_DOWNLOAD_DIR"
find "$GOOGLE_DOWNLOAD_DIR" -type f | xargs -o -n 1000 vim "+set nomore" "+bufdo set nobomb fileencoding=utf8 | update" "+quit"
