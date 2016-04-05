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

    install_vim
    install_git
    install_subversion

    # skip java in travis, takes too long
    if [ -z "$TRAVIS" ]; then
        install_java_tools
    fi
    install_devops_tools

    echo Done
}

install_subversion() {
    if [ ! -d "/home/$USERNAME/.subversion" ]; then
        apt-get update -qq && apt-get install -y -qq subversion
        ln -s "$(pwd)/home/.subversion" "/home/$USERNAME/.subversion"
        chown $USERNAME:$USERNAME "/home/$USERNAME/.subversion"
    fi
}

install_git() {
    # git is already installed, just configure

    if [ ! -f "/home/$USERNAME/.gitconfig" ]; then
        ln -s "$(pwd)/home/.gitconfig" "/home/$USERNAME/.gitconfig"
        chown $USERNAME:$USERNAME "/home/$USERNAME/.gitconfig"
    fi
}

install_vim() {
    # vim is already installed, just configure

    # install Vundle if not present
    if [ ! -d "/home/$USERNAME/.vim/bundle/Vundle.vim" ]; then
        git clone "https://github.com/gmarik/Vundle.vim.git" "/home/$USERNAME/.vim/bundle/Vundle.vim"
        chown -R $USERNAME:$USERNAME "/home/$USERNAME/.vim"
        ln -s "$(pwd)/home/.vimrc" "/home/$USERNAME/.vimrc"
        chown $USERNAME:$USERNAME "/home/$USERNAME/.vimrc"
    fi
}

install_basic_tools() {
    apt-get update -qq && apt-get install -y -qq subversion vim tree python-pip python3-pip sshfs cifs-utils 
}

install_devops_tools() {
    install_ansible
    install_vagrant
    install_packer
    install_docker
}

install_java_tools() {
    install_oracle_java 8
    apt-get install -y -qq ant ant-contrib maven
}

install_oracle_java() {
    apt-add-repository ppa:webupd8team/java -y
    echo oracle-java$1-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
    apt-get update -qq && apt-get install -y -qq oracle-java$1-installer oracle-java$1-set-default
}

install_packer() {
    if ! program_exists packer; then
        local PACKER_VERSION="0.10.0"
        wget --directory-prefix="/usr/local/bin/" "https://releases.hashicorp.com/packer/$PACKER_VERSION/packer_${PACKER_VERSION}_linux_amd64.zip"
        # -o tells unzip to overwrite existing files
        unzip -o "/usr/local/bin/packer_${PACKER_VERSION}_linux_amd64.zip" -d "/usr/local/bin/"
        rm "/usr/local/bin/packer_${PACKER_VERSION}_linux_amd64.zip"
    fi
}

install_ansible() {
    if ! program_exists ansible; then
        apt-add-repository ppa:ansible/ansible -y
        apt-get update -qq && apt-get install -y -qq ansible vagrant
        ! grep --quiet "export ANSIBLE_NOCOWS" && echo "export ANSIBLE_NOCOWS=1" >> "/home/$USERNAME/.bashrc"
    fi
}

install_vagrant() {
    if ! program_exists vagrant; then
        apt-get update -qq && apt-get install -y vagrant
    fi
}

install_docker() {
    # install docker-engine
    if ! program_exists docker; then
        apt-key adv --keyserver "hkp://p80.pool.sks-keyservers.net:80" --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
        echo "deb https://apt.dockerproject.org/repo ubuntu-$(lsb_release -cs) main" > "/etc/apt/sources.list.d/docker.list"
        apt-get update -qq && apt-get install -y linux-image-extra-$(uname -r) docker-engine
        # allow running docker without sudo
        usermod -aG docker $USERNAME
    fi

    # install docker-machine
    if ! program_exists docker-machine; then
        curl -L "https://github.com/docker/machine/releases/download/v0.6.0/docker-machine-$(uname -s)-$(uname -m)" > "/usr/local/bin/docker-machine"
        chmod +x /usr/local/bin/docker-machine
    fi

    # install docker-compose
    if ! program_exists docker-compose; then
        curl -L "https://github.com/docker/compose/releases/download/1.6.2/docker-compose-$(uname -s)-$(uname -m)" > "/usr/local/bin/docker-compose"
        chmod +x "/usr/local/bin/docker-compose"
    fi
}

program_exists() {
    hash "$1" 2>/dev/null
}

check_root() {
    if [ "$(whoami)" != "root" ]; then
        echo "Must be root."
        exit 1
    fi
}

main
