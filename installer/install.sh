#!/usr/bin/env bash

# This is a plain bash script installer, it doesn't use ansible.

WORKING_DIRECTORY=/tmp/dev-env-plain-installer
DOWNLOAD_CACHE_DIRECTORY=$WORKING_DIRECTORY/cache
UBUNTU_CODENAME=trusty
USERNAME=$SUDO_USER

# Java
# temporarily comment out java since it takes tens of minutes to download
PACKAGES="oracle-java7-installer oracle-java8-installer oracle-java8-set-default"


# Virtualization
PACKAGES="$PACKAGES virtualbox-4.3 dkms lxc-docker cgroup-lite apparmor"
#TODO vagrant (not in apt-get)?

# SVC
PACKAGES="$PACKAGES git subversion mercurial kdiff3"

# Build tools
PACKAGES="$PACKAGES ant jenkins"
MAVEN_VERSION="3.2.5"
M2_HOME=/usr/local/maven

# DB
PACKAGES="$PACKAGES postgresql-9.3"

# Misc
PACKAGES="$PACKAGES vim tree ansible curl python-pip python3-pip chromium-browser skype remmina remmina-plugin-rdp"
#TODO jedit eclipse?

##################################################
# Prepare

mkdir -p $WORKING_DIRECTORY
mkdir -p $DOWNLOAD_CACHE_DIRECTORY

# Ansible
apt-add-repository ppa:ansible/ansible -y

# Java
apt-add-repository ppa:webupd8team/java -y

# VirtualBox
wget -q -O - https://www.virtualbox.org/download/oracle_vbox.asc | apt-key add -
echo "deb http://download.virtualbox.org/virtualbox/debian $UBUNTU_CODENAME contrib" > /etc/apt/sources.list.d/virtualbox.list

# Docker
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
echo "deb http://get.docker.com/ubuntu docker main" > /etc/apt/sources.list.d/docker.list

# Jenkins
wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
echo "deb http://pkg.jenkins-ci.org/debian binary/" > /etc/apt/sources.list.d/jenkins.list

# Skype
apt-add-repository "deb http://archive.canonical.com/ $UBUNTU_CODENAME partner"

# Accept Oracle License
echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections

apt-get update

##################################################
# Upgrade

apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" dist-upgrade

##################################################
# Install

apt-get install $PACKAGES -y

# Maven
mkdir -p $M2_HOME
wget --progress=dot:mega http://apache.mirrors.lucidnetworks.net/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz -O $DOWNLOAD_CACHE_DIRECTORY/apache-maven-bin.tar.gz
tar --strip-components=1 -xzf $DOWNLOAD_CACHE_DIRECTORY/apache-maven-bin.tar.gz -C $M2_HOME

##################################################
# Configure

# Git
cat > /home/$USERNAME/.gitconfig <<"EOL"
[push]
        default = simple
[diff]
        tool = vimdiff
[merge]
        tool = vimdiff
[difftool]
        prompt = false
EOL
chown $USERNAME:$USERNAME /home/$USERNAME/.gitconfig

# Vim
cat > /home/$USERNAME/.vimrc <<"EOL"
:set nowrap
:set tabstop=4
EOL
chown $USERNAME:$USERNAME /home/$USERNAME/.vimrc

# Bash
echo "export M2_HOME=$M2_HOME" > /home/$USERNAME/.bashrc
cat >> /home/$USERNAME/.bashrc <<"EOL"
export PATH=$PATH:$M2_HOME/bin

# Show current directory in terminal window title
PROMPT_COMMAND='echo -ne "\033]0;`basename ${PWD}` ${PWD}\007"'

export ANSIBLE_NOCOWS=1

alias lll="ll --color=always | less -R"
EOL
chown $USERNAME:$USERNAME /home/$USERNAME/.bashrc

