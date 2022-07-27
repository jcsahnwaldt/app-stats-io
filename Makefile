
all: download process

download: download_google download_apple

process: process_google process_apple

download_google:
	time ruby download_google.rb

download_apple:
	time ruby download_apple.rb

process_google:
	time ruby process_google.rb

process_apple:
	time ruby process_apple.rb

clean:
	$(RM) -r venv/
