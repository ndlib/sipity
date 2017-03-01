#!/bin/bash
#
# Copy the relevant secrets from the build server to the app server.
#
# TODO update script to perform the correct function
#
# usage:
#   ./copy_secrets.sh <secret directory> <target host>

secret_dir=$1
app_host=$2

files_to_copy="
    config/application.yml
    config/database.yml
    config/newrelic.yml
    config/environment_bootstrapper.rb
    config/locales/site-specific.yml
    app/assets/stylesheets/theme/_default.scss
    "

for f in $files_to_copy; do
    echo "=-=-=-=-=-=-=-= copy $f"
    if [ -f "$secret_dir/$f" ];
    then
        scp -rv "$secret_dir/$f" "app@$app_host:/home/app/shared/$f"
    else
        echo "Fatal Error: File $f does not exist in $secret_dir"
        exit 1
    fi
done
