# Specify the shell
SHELL := bash

# Get path of this Makefile
MAKEFILE_PATH :=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# Get name of this Makefile
MAKE_FILENAME := $(lastword $(MAKEFILE_LIST))

# Include utilities like colors
include ${MAKEFILE_PATH}/utilities.mk

# ==============
#   EDIT THIS
# ==============
# Where the app is located.
# Make sure this Makefile is inside a directory inside the app (ex. bedrock-app/wp-sync/sync.mk)
LOCAL_APP_PATH = $(shell dirname "${MAKEFILE_PATH}")

# The path to where the WP core is located in order to call this recipe from anywhere
WP_CORE_PATH = ${LOCAL_APP_PATH}/web/wp/

# If using Elementor, set this to true.
ELEMENTOR = false

# Sync codebase dir (theme, plugins, etc...)
# If syncing all of it for the first time, just leave a trailing slash '/'.
SYNC_CODE_PATH = /web/app/
# Sync database dir
SYNC_DB_PATH   = db/

# SSH Port (if other than 22)
REMOTE_SSH_PORT = 22
# Name of Server User Account connecting to
REMOTE_USER     = 
# Hostname or IP address of server connecting to
REMOTE_HOSTNAME = s1.domain.com
# Server path
REMOTE_APP_PATH = /home/${REMOTE_USER}/webapps/domain
# List of files/folders to be excluded
EXCLUDE_LIST    = ${MAKEFILE_PATH}/exclude.txt

# Syncing from ...
CODEBASE_FROM = ${LOCAL_APP_PATH}${SYNC_CODE_PATH}
DATABASE_FROM = ${LOCAL_APP_PATH}/${SYNC_DB_PATH}

# Syncing to ...
CODEBASE_TO = ${REMOTE_USER}@${REMOTE_HOSTNAME}:${REMOTE_APP_PATH}${SYNC_CODE_PATH}
DATABASE_TO = ${REMOTE_USER}@${REMOTE_HOSTNAME}:${REMOTE_APP_PATH}/${SYNC_DB_PATH}

# DB options
DB_NAME   = $(shell wp --path="${WP_CORE_PATH}" config get DB_NAME)
DB_EXPORT = ${LOCAL_APP_PATH}/${SYNC_DB_PATH}dev-${DB_NAME}-${TIMESTAMP}.sql

#---------------------------------------------
# Save WP Database
#---------------------------------------------
start:
	@echo "${SEPARATOR}"
	@echo "SYNCING..."
	@echo "${RED}FROM${RESET_COLOR}: ${BLUE}${CODEBASE_FROM}${RESET_COLOR}"
	@echo "  ${RED}TO${RESET_COLOR}: ${LIGHTPURPLE}${REMOTE_APP_PATH}${SYNC_CODE_PATH}${RESET_COLOR}"
	@read -p "${YELLOW}Do you wish to continue?${RESET_COLOR} " -n 1 -r; \
		echo "";\
	if [[ $$REPLY =~ ^[Yy] ]]; \
	then \
		echo "";\
		echo "${GREEN}Starting${RESET_COLOR} ...";\
		make -f ${MAKE_FILENAME} execute;\
		echo "";\
	fi


#---------------------------------------------
# Order of the sync steps
#---------------------------------------------
execute: rsync_code dump_db rsync_db ssh_remote

#---------------------------------------------
# Sync Codebase Directory
#---------------------------------------------
rsync_code:
	@echo "${LIGHTPURPLE}${SEPARATOR}${RESET_COLOR}"
	@echo "  ${LIGHTPURPLE}Syncing files ...${RESET_COLOR}"
	@echo "${LIGHTPURPLE}${SEPARATOR}${RESET_COLOR}"
	@if [ ${ELEMENTOR} = true ]; then \
		wp --path="${WP_CORE_PATH}" elementor flush_css; \
	fi
	@wp --path="${WP_CORE_PATH}" cache flush
	@rsync -avzhe "ssh -p ${REMOTE_SSH_PORT}" --exclude-from="${EXCLUDE_LIST}" "${CODEBASE_FROM}" "${CODEBASE_TO}"
	@echo "${GREEN}Success:${RESET_COLOR} Codebase has been synced."

#---------------------------------------------
# Save WP Database
#---------------------------------------------
dump_db:
	@echo "${LIGHTPURPLE}${SEPARATOR}${RESET_COLOR}"
	@echo "  ${LIGHTPURPLE}Exporting LOCAL DB ...${RESET_COLOR}"
	@echo "${LIGHTPURPLE}${SEPARATOR}${RESET_COLOR}"
	@if [ ! -d ${LOCAL_APP_PATH}/${SYNC_DB_PATH} ]; then mkdir -p ${LOCAL_APP_PATH}/${SYNC_DB_PATH}; fi
	@wp --path="${WP_CORE_PATH}" db repair --quiet && wp --path="${WP_CORE_PATH}" db optimize --quiet
	@wp --path="${WP_CORE_PATH}" db export "${DB_EXPORT}"

#---------------------------------------------
# Sync Database Directory
#---------------------------------------------
rsync_db:
	@echo "${LIGHTPURPLE}${SEPARATOR}${RESET_COLOR}"
	@echo "  ${LIGHTPURPLE}Syncing Database ...${RESET_COLOR}"
	@echo "${LIGHTPURPLE}${SEPARATOR}${RESET_COLOR}"
	@rsync -avzhe "ssh -p ${REMOTE_SSH_PORT}" --exclude-from="${EXCLUDE_LIST}" "${DATABASE_FROM}" "${DATABASE_TO}"
	@echo "${GREEN}Success:${RESET_COLOR} Database has been synced."

#---------------------------------------------
# SSH to Remote host
#---------------------------------------------
ssh_remote:
	@echo "${LIGHTPURPLE}${SEPARATOR}${RESET_COLOR}"
	@echo "  ${LIGHTPURPLE}Connecting to remote server ...${RESET_COLOR}"
	@echo "${LIGHTPURPLE}${SEPARATOR}${RESET_COLOR}"
	@ssh -t ${REMOTE_USER}@${REMOTE_HOSTNAME}  -p ${REMOTE_SSH_PORT} "cd ${REMOTE_APP_PATH}/ ; bash --login"

#---------------------------------------------
# Use this to run tests
#---------------------------------------------
test:
	@echo "test"
	