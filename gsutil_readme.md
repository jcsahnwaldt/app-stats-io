gsutil is only needed to generate the Google access token:
run `gsutil_install.sh` and copy the value of `gs_oauth2_refresh_token` from `.boto` to `config.rb`

- `gsutil_install.sh` installs gsutil in local `venv/` dir and creates file `.boto`
- `gsutil_uninstall.sh` removes local `venv/` dir
- `gsutil_download.sh` is similar to `download_google.rb`, but much slower
