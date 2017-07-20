#!/bin/bash
#
# Copy the preproduction secrets to the correct place for deployment
#
# This runs on the worker VM and on the cluster
#
# usage:
#   ./update_secrets.sh <name of secret repo>

secret_repo=$1

if [ -d $secret_repo ]; then
    echo "=-=-=-=-=-=-=-= delete $secret_repo"
    rm -rf $secret_repo
fi
echo "=-=-=-=-=-=-=-= git clone $secret_repo"
git clone "git@git.library.nd.edu:$secret_repo"

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
    if [ -f $secret_repo/sipity/$f ];
    then
        cp $secret_repo/sipity/$f $f
    else
        echo "Fatal Error: File $f does not exist in $secret_repo/sipity"
        exit 1
    fi
done
