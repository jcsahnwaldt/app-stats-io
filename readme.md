# util-app-stats

Command-line tools for downloading and processing statistics about a mobile
app from Google and Apple.

The download scripts [`download_google.rb`](download_google.rb) and 
[`download_apple.rb`](download_apple.rb) should work well for anyone
as they are.

The processing scripts [`process_google.rb`](process_google.rb)
and [`process_apple.rb`](process_apple.rb) are mostly examples that
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

Tested on macOS (10.14 Mojave), but should also work on Linux, and maybe even Windows.

## Usage

### Installation

Clone this repository.

TODO: list required Ruby gems.

### Configuration

Find (or generate) the following configuration values:

* Your Google access token
* Your Google bucket ID
* Your Apple access token
* Your Apple vendor ID

See [`config_template.rb`](config_template.rb) for details. TODO: describe
how to find / generate the values.

Create folders in which you want to store the downloaded / processed data.

### Execution

* [`download_google.rb`](download_google.rb): download Google data
* [`download_apple.rb`](download_apple.rb): download Apple data
* [`process_google.rb`](process_google.rb): process Google data
* [`process_apple.rb`](process_apple.rb): process Apple data

A convenient way to configure the scripts is copying `config_template.rb` to
`config.rb` and replacing the example values with your configuration data.
When the download and process commands are called without arguments, they read
their configuration from `config.rb`.

Creating `config.rb` is not strictly necessary though: If one of the commands
is called with command line arguments, it ignores `config.rb` and takes all
its configuration values from the arguments.

You can also use these [`Makefile`](Makefile) targets:

* `make download_google`: download Google data
* `make download_apple`: download Apple data
* `make process_google`: process Google data
* `make process_apple`: process Apple data
* `make download`: download all data
* `make process`: process all data
* `make all` or just `make`: download and process all data

Since the `Makefile` targets call the scripts without arguments, they require `config.rb`.

## Known issues

The code could use some comments, especially [`pipe.rb`](pipe.rb).
