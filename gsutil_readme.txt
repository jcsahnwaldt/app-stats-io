gsutil is only needed to generate the Google access token:
run gsutil_install.sh and copy gs_oauth2_refresh_token from .boto to config.rb

gsutil_install.sh installs gsutil in local venv/ dir and creates .boto

gsutil_uninstall.sh removes venv/

gsutil_download.sh does the same thing as download_google.rb, but much slower
