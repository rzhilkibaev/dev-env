#!/usr/bin/env bash

set -e
set -o pipefail

# Check for root privileges
if [ "$(whoami)" != "root" ]; then
	echo "Must be root."
	exit 1
fi

USERNAME=$SUDO_USER

PACKAGES="git subversion vim curl python-pip python3-pip tree"

# Java
apt-add-repository ppa:webupd8team/java -y
PACKAGES="$PACKAGES oracle-java8-installer oracle-java8-set-default ant ant-contrib"
#PACKAGES="$PACKAGES oracle-java7-installer oracle-java8-installer oracle-java8-set-default ant ant-contrib"
echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections

# Ansible
apt-add-repository ppa:ansible/ansible -y
PACKAGES="$PACKAGES ansible"

# install
apt-get update && apt-get install -y $PACKAGES

# Vagrant 
wget -q https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.2_x86_64.deb -O /tmp/vagrant.deb
dpkg -i /tmp/vagrant.deb
rm -f /tmp/vagrant.deb

# Maven
MAVEN_VERSION="3.2.5"
M2_HOME=/usr/local/maven
mkdir -p $M2_HOME
wget -qO- http://apache.mirrors.lucidnetworks.net/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar --strip-components=1 -xzC $M2_HOME
