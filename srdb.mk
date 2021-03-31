# Specify the shell
SHELL := bash

# Get path of this Makefile
MAKEFILE_PATH :=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# Where the app is located.
# Make sure this Makefile is inside a directory inside the app (ex. bedrock-app/wp-sync/srdb.mk)
LOCAL_APP_PATH = $(shell dirname "${MAKEFILE_PATH}")

# The path to where the WP core is located in order to call this recipe from anywhere
WP_CORE_PATH = ${LOCAL_APP_PATH}/public_html/wp/

# If using Elementor, set this to true.
ELEMENTOR = false

# Site URL
OLD_URL = https://domain.test
NEW_URL = https://www.domain.com

# Commands to execute

execute:
	@echo "Updating URL in Database ..."
	@wp --path="${WP_CORE_PATH}" search-replace "${OLD_URL}" "${NEW_URL}" --all-tables
	@wp --path="${WP_CORE_PATH}" elementor replace_urls "${OLD_URL}" "${NEW_URL}"
	@wp --path="${WP_CORE_PATH}" elementor flush_css
	@wp --path="${WP_CORE_PATH}" cache flush
	@echo "Done!"

test:
	@echo "Test"
