# util-app-stats

Command-line tools for downloading and processing statistics about a mobile
app from Google and Apple.

The download scripts [`download_google.rb`](download_google.rb) and 
[`download_apple.rb`](download_apple.rb) download all available statistics
files. You probably won't need them all, but the download usually only takes
a couple of seconds.

The processing scripts [`process_google.rb`](process_google.rb)
and [`process_apple.rb`](process_apple.rb) are mostly examples that
you should probably modify before running them &ndash; they are fine for me,
but your data processing needs will likely be different.

# Requirements

- Tested on macOS (10.14 Mojave), but should also work on Linux, and maybe even Windows.
- Tested with Ruby 2.7.1 and 3.0.0, older versions may not work.
- Python 3 for Google configuration

# Installation

Clone this repository:

```
git clone https://github.com/jcsahnwaldt/util-app-stats.git
cd util-app-stats
```

Copy `config_template.rb` to `config.rb`.

Note: All values in `config.rb` should be in single quotes.

## Install Ruby libxml for reading / writing XML

*TODO: improve `pipe.rb`: users who don't want to read/write XML
should not have to install this gem.*

```
gem install libxml-ruby
```

On my Mac, I got an error message that a C header file could not be found.
I managed to install libxml-ruby by running

```
gem install libxml-ruby -- --with-xml2-config=/usr/bin/xml2-config
```

On Linux, you may have to install `libxml2-dev` first, e.g.

```
sudo apt-get install libxml2-dev
```

## Install Ruby sqlite3 for reading / writing SQLite

*TODO: improve `pipe.rb`: users who don't want to read/write SQLite
should not have to install this gem.*

```
gem install sqlite3
```

On Linux, you may have to install `libsqlite3-dev` first, e.g.

```
sudo apt install libsqlite3-dev
```

## Google configuration

```
gem install google-cloud-storage
```

### Google access token

```
./gsutil_install.sh
```

This installs the GSUtil Python tool in ./venv and then lets you create
credentials through Google's web interface:

- Copy the authorization code from the browser to the command line.
- When the command line tool asks for the project-id, enter any non-empty value.
  You don't need a Google Cloud project.
- The tool will create a .boto file.
- Copy the value of gs_oauth2_refresh_token from .boto into the value of
  GOOGLE_TOKEN in config.rb.

### Google bucket ID

Go to https://play.google.com/console/developers/download-reports/statistics ,
click 'Copy Cloud Storage URI', paste the part that look like
'pubsite_prod_rev_12345678901234567890' into GOOGLE_BUCKET in config.rb.

## Apple configuration

### Apple access token

Go to https://appstoreconnect.apple.com/trends/reports
\> About Reports \> Generate Reporter Token

Copy it into the value of `APPLE_TOKEN` in `config.rb`.

### Apple vendor ID

https://appstoreconnect.apple.com/trends/reports
\> vendor ID is the number next to your name

Copy it into the value of APPLE_VENDOR in config.rb.

### Folder path configuration

Create folders in which you want to store the downloaded / processed data.

A convenient way to configure the scripts is copying `config_template.rb` to
`config.rb` and replacing the example values with your configuration data.

## Execution

* [`download_google.rb`](download_google.rb) - download Google data
* [`download_apple.rb`](download_apple.rb) - download Apple data
* [`process_google.rb`](process_google.rb) - process Google data
* [`process_apple.rb`](process_apple.rb) - process Apple data

When the download and process commands are called without arguments, they read
their configuration from `config.rb`.

Creating `config.rb` is not strictly necessary though: If one of the commands
is called with command line arguments, it ignores `config.rb` and takes all
its configuration values from the arguments.

You can also use these [`Makefile`](Makefile) targets:

* `make download_google` - download Google data
* `make download_apple` - download Apple data
* `make process_google` - process Google data
* `make process_apple` - process Apple data
* `make download` - download all data
* `make process` - process all data
* `make all` or just `make` - download and process all data

Since the `Makefile` targets call the scripts without arguments, they require `config.rb`.

## pipe.rb

[`pipe.rb`](pipe.rb) is a little Ruby library that lets one describe
complex pipelines for reading, processing and writing tabular data
from and to CSV, XML and SQLite files with a few lines of code.
Some of its features (but by far not all) are used in [`process.rb`](process.rb),
[`process_google.rb`](process_google.rb) and [`process_apple.rb`](process_apple.rb).

## Known issues

The code could use some comments, especially [`pipe.rb`](pipe.rb).
