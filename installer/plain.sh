#!/usr/bin/env bash

# this is plain bash script installer, it doesn't use ansible.

WORKING_DIRECTORY=/var/tmp/dev-env-plain-installer
DOWNLOAD_CACHE_DIRECTORY=$WORKING_DIRECTORY/cache
LOG_FILE=$WORKING_DIRECTORY/log.txt

#Java
PACKAGES=oracle-java7-installer oracle-java8-installer oracle-java8-set-default

# VirtualBox
PACKAGES=$PACKAGES virtualbox-4.3 dkms

# SVC
PACKAGES=$PACKAGES git subversion mercurial

# Misc
PACKAGES=$PACKAGES ant vim tree ansible

mkdir -p $WORKING_DIRECTORY

echo "Adding ppa repositories"
apt-add-repository ppa:ansible/ansible -y >> $LOG_FILE
apt-add-repository ppa:webupd8team/java -y >> $LOG_FILE
grep -q -F 'virtualbox' /etc/apt/sources.list || echo "deb http://download.virtualbox.org/virtualbox/debian trusty contrib" >> /etc/apt/sources.list
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | apt-key add - >> $LOG_FILE
apt-get update >> $LOG_FILE

echo "Installing"

apt-get install $PACKAGES -y >> $LOG_FILE


