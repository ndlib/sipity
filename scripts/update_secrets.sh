#!/bin/bash
#
# Copy the secrets to the correct place for deployment
#
# usage:
#   ./update_secrets.sh

# based directory where ansible builds secrets file
secret_directory='/home/app/sipity/shared/secret'

files_to_copy="
    config/application.yml
    config/database.yml
    config/environment_bootstrapper.rb
    config/locales/site-specific.yml
    app/assets/stylesheets/theme/_default.scss
    "
# Assumes we are in sipity repo rootdir
for f in $files_to_copy; do
    echo "=-=-=-=-=-=-=-= copy $f"
    if [ -f $secret_directory/$f ];
    then
        cp $secret_directory/$f $f
    else
        echo "Fatal Error: File $f does not exist in $secret_directory"
        exit 1
    fi
done
