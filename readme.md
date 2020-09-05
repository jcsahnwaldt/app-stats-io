# util-app-stats

Command-line tools for downloading and processing statistics about your
mobile app from Google and Apple.

The download scripts [`download_google.rb`](download_google.rb) and 
[`download_apple.rb`](download_apple.rb) should work well for anyone
as they are, but the processing scripts [`process_google.rb`](process_google.rb)
and [`process_apple.rb`](process_apple.rb) are merely examples that
you should probably modify before running them - they are fine for me,
but your data processing needs will likely be different.

## pipe.rb

[`pipe.rb`](pipe.rb) is a little Ruby library that lets one describe
complex pipelines for reading, processing and writing tabular data
from and to CSV, XML and SQLite files with a few lines of code.
Many of its features (but by far not all) are used in [`process.rb`](process.rb),
[`process_google.rb`](process_google.rb) and [`process_apple.rb`](process_apple.rb).

## Requirements

Tested with Ruby 2.7.1, older versions may not work.

TODO: list required Ruby gems.

## Usage

Clone this repo. Then find (or generate) the following configuration values:

* Your Google access token
* Your Google bucket ID
* Your Apple access token
* Your Apple vendor ID

See [`config_template.rb`](config_template.rb) for details.

Create folders in which you want to store the downloaded / processed data.

The most convenient way to configure the download and processing scripts is
copying `config_template.rb` to `config.rb` and replacing the example values
with your configuration data.

* [`download_google.rb`](download_google.rb) downloads Google data
* [`download_apple.rb`](download_apple.rb) downloads Apple data
* [`process_google.rb`](process_google.rb) processes Google data
* [`process_apple.rb`](process_apple.rb) processes Apple data

When one of these scripts is called without arguments, it reads its configuration
from `config.rb`. Creating `config.rb` is not strictly necessary though: If one
of these commands is called with command line arguments, it ignores `config.rb`
and takes all its configuration values from the arguments.

You can also use these [`Makefile`](Makefile) targets:

* `make download_google` downloads Google data
* `make download_apple` downloads Apple data
* `make download` downloads all data
* `make process_google` processes Google data
* `make process_apple` processes Apple data
* `make process` processes all data
* `make all` or just `make` downloads and processes all data

Since the `Makefile` targets call the scripts without arguments, they require `config.rb`.

## Known issues

The code could use some comments, especially [`pipe.rb`](pipe.rb).
