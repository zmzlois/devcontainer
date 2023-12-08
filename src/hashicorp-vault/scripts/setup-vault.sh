#!/bin/bash
set -e

# check a file for the given string if it exists do nothing. If it doesn't exist, add the string to the file.
checkFileForString() {
    # make sure the directory exists
    dirname "$2" | xargs mkdir -p
    if ! grep -sq "$1" "$2"; then
        echo "$1" >> "$2"
    fi
}

if [ -z "$HCP_CLIENT_ID" ]; then 
    echo "You don't have a HCP_CLIENT_ID set up yet, you can set it up in your Daytona dashboard, or login manually \
    Please make sure you have create a service principal within the IAM access control panel,\ 
    and copy the client ID for the next step \ 
    Once you have the client id, run this command as followed \
    export HCP_CLIENT_ID=<client_id>"

    exit 0
fi

if [ -z "$HCP_CLIENT_SECRET" ]; then 
    echo "You don't have a HCP_CLIENT_SECRET set up yet, you can set it up in your Daytona dashboard, or login manually \
    Please make sure you have create a service principal within the IAM access control panel,\
    and copy the client secret for the next step \
    Once you have the client secret, run this command as followed \
    export HCP_CLIENT_SECRET=<client_secret>"

    exit 0
fi

echo "Checking your vault secret key lists..."

vlt secrets list
