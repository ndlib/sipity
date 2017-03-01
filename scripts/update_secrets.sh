#!/bin/bash
#
# Copy the secrets from the shared capistrno directory to the release directory
#
# usage:
#   ./update_secrets.sh <directory of secrets>

secret_dir=$1

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
        cp "$secret_dir/$f" "$f"
    else
        echo "Fatal Error: File $f does not exist in $secret_dir"
        exit 1
    fi
done
