#!/bin/bash -e

cd "$(dirname "$0")"
source venv/bin/activate
source config.rb
BOTO_CONFIG=.boto gsutil -m cp -r gs://$GOOGLE_BUCKET/* "$GOOGLE_DOWNLOAD_DIR"
# strip GOOGLE_APP_ID from file names
find "$GOOGLE_DOWNLOAD_DIR" -name "*${GOOGLE_APP_ID}_*" | while read f ; do mv -f $f ${f/${GOOGLE_APP_ID}_/} ; done
# files are in UTF-16, use vim to convert to UTF-8
find "$GOOGLE_DOWNLOAD_DIR" -type f | xargs -o -n 1000 vim "+set nomore" "+bufdo set nobomb fileencoding=utf8 | update" "+quit"
