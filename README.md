# Sync WP Site Makefile Recipe

> A quick recipe to sync your codebase and database from a local host to a remote one.

If you love developing with [Bedrock](https://roots.io/bedrock/) and [Laravel Valet](https://laravel.com/docs/8.x/valet) and haven't found a simple deployment strategy, follow along!

## Usage

1. Make sure you have set up remote directory to sync with local.

	**LOCALLY**

2. Install Bedrock to your directory of choice *(in this case to "bedrock-app")*:
	```sh
  	$ composer create-project roots/bedrock bedrock-app
	```
3. Configure Bedrock as needed. **Pay attention to your local & remote paths**.
4. Clone or [download](https://github.com/lopadz/wp-sync/archive/refs/heads/main.zip) to a directory inside your app. *(ex. bedrock-app/wp-sync/sync.mk)*
	```sh
	$ git clone https://github.com/lopadz/wp-sync
	```
5. Configure the `sync.mk` & `srdb.mk` files to match your project needs.
6. When you're ready to sync to remote, `cd` to your project's directory and run:
   ```sh
  	$ make -f wp-sync/sync.mk
  	```
7. Double-check the paths and press <kbd>y</kbd> to run the makefile. Press any other key to exit.
8. If everything worked, it will open a new connection to the remote host and `cd` you into the project's directory.

	**REMOTELY**

10. Make sure your DB credentials in the remote .env *(or wp-config.php)* file have been configured.
11. Reset and/or import the synced db:
	```sh
	$ wp db reset
	```
	or
	```sh
	$ wp db reset && wp db import db/DB_NAME_HERE.sql
	```
12. Make sure `srdb.mk` has been configured with old and new URLs.
13. Run this to search & replace URLs in the remote database:
	```sh
  	$ make -f wp-sync/srdb.mk
  	```

## Assumptions & other notes

- Both local and remote hosts have Bash shell and [WP-CLI](https://wp-cli.org/) installed.
- SSH connection to remote host is set up and working.
- If SSH key has passphrase, it will need to be entered multiple times. :shrug:
- The makefile can be called from anywhere--the script will detect where it's located and use relative paths to run the commands. However, when you call it, make sure you add the path relative to where you are located. For example, 
	- If you are in ```~/dev/sites/```
	- and the app is in ```~/dev/sites/bedrock-app/```
	- then run:
	```sh
	$ make -f bedrock-app/wp-sync/sync.mk
	```
- The recipe exports the database to: `db/dev-DATABASE_NAME-YYYY-MM-DD-HHMMSS.sql`. To change the path or filename, update lines 30, 52, 53.
- If you would like to completely mirror both local and remote directories, you could pass a --delete flag in lines 90 & 111. **Be very careful with this flag. If paths are configured incorrectly, this could delete files not meant to be deleted.**

If you only need to run a specific step in the `sync.mk` script, run:
  ```sh
  $ make -f wp-sync/sync.mk step_name_here
  ```
Available steps are:
- **rsync_code**: Syncs the codebase directory.
- **dump_db**: Exports the local db.
- **rsync_db**: Syncs the database directory.
- **ssh_remote**: SSH into the remote host.
