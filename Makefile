include config.rb

all: download process

download: download_apple download_google

process: process_apple process_google

download_apple:
	time ruby download_apple.rb $(APPLE_TOKEN) $(APPLE_VENDOR) $(APPLE_DELAY) $(APPLE_DOWNLOAD_DIR)

download_google:
	time ruby download_google.rb $(GOOGLE_TOKEN) $(GOOGLE_BUCKET) $(GOOGLE_DELAY) $(GOOGLE_DOWNLOAD_DIR) $(GOOGLE_APP_ID)

process_apple:
	time ruby process_apple.rb $(APPLE_DOWNLOAD_DIR) $(APPLE_PROCESS_PREFIX)

process_google:
	time ruby process_google.rb $(GOOGLE_DOWNLOAD_DIR) $(GOOGLE_PROCESS_PREFIX) $(GOOGLE_VERSIONS_FILE)
