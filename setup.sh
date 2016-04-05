#!/usr/bin/env bash

# Usage: setup.sh
#
# Guidelines
# - This script is executed once in a few months, execution speed doesn't matter much. Readability does.
# - Each install_* and configure_* function should be independent.

#set -x
set -eo pipefail


USERNAME=$SUDO_USER
export DEBIAN_FRONTEND=noninteractive

function main() {
    
    check_root

    # skip java in travis, takes too long
    if [ -z "$TRAVIS" ]; then
        install_java_tools
    fi
    install_devops_tools

}

check_root() {
    if [ "$(whoami)" != "root" ]; then
        echo "Must be root."
        exit 1
    fi
}

install_devops_tools() {
    apt-add-repository ppa:ansible/ansible -y
    apt-get update && apt-get install -y ansible vagrant
    #install_packer
    #install_docker

}

install_java_tools() {
    install_oracle_java 8
    apt-get install -y ant ant-contrib maven
}

install_oracle_java() {
    apt-add-repository ppa:webupd8team/java -y
    echo oracle-java$1-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
    apt-get update && apt-get install -y oracle-java$1-installer oracle-java$1-set-default
}

main
