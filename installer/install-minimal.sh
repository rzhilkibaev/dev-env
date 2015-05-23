#!/usr/bin/env bash

set -e
set -o pipefail

# Check for root privileges
if [ "$(whoami)" != "root" ]; then
	echo "Must be root."
	exit 1
fi

USERNAME=$SUDO_USER

# docker
#wget -qO- https://get.docker.com/ | sh
usermod -aG docker $USERNAME

PACKAGES="git subversion mercurial vim curl python-pip python3-pip apt-file tree ansible"

##################################################
# Prepare

# Ansible
apt-add-repository ppa:ansible/ansible -y

# install
apt-get update
apt-get install -y $PACKAGES
