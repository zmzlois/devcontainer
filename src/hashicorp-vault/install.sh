#!/bin/sh
# Set shell to exit on error
set -e

echo "Activating feature 'hashicorp-vault'"

COMPLETION=${COMPLETION:-true}
echo "Hashicorp Vault completion files installed: $COMPLETION"

# TODO: decide whether to use this later
# VAULT_VERSION=${VAULT_VERSION:-1.7.3}


# Tell hashicorp we are developing remotely as a remote user 
# Check https://containers.dev/implementors/features/#user-env-var 
DIRECTORY="$_REMOTE_USER_HOME"


export DEBIAN_FRONTEND=noninteractive

# Check what packages exists in this OS and update them if any
apt_get_update()
{
     if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

# check if packages listed are installed and if not, install them
check_packages()
{
     if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
    fi
}

apt_get_update
check_packages curl apt-transport-https gnupg ca-certificates

# Update `apt` package management tool, can be deleted but recommended by hashicorp
sudo apt update 

# Download the hashicorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add the HashCorp Repo
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Fetch and install the latest hashicorp vault CLI
sudo apt update && sudo apt install vlt -y

# Below are for setting up vault CLI 
mkdir -p /usr/local/share/hashicorp
cp ${PWD}/scripts/setup-vault.sh /usr/local/share/hashicorp/setup-vault.sh
chmod +x /usr/local/share/hashicorp/setup-vault.sh

if [ "$COMPLETION" = "true" ]; then
    apt-get install -y bash-completion

    mkdir -p /usr/share/bash-completion/completions
    vlt completion install bash

    mkdir -p /usr/local/share/zsh/site-functions
    vlt completion install zsh
fi

# Clean up
rm -rf /var/lib/apt/lists/* /tmp/vlt
