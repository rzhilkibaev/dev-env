#!/usr/bin/env bash

# Usage: setup.sh
#
# Guidelines
# - This script is executed once in a few months, execution speed doesn't matter much. Readability does.
# - Each install_* function should be independent.

#set -x
set -eo pipefail

USERNAME=$SUDO_USER
export DEBIAN_FRONTEND=noninteractive

function main() {
    
    check_root

    install_basic_tools

    install_vim
    install_git
    install_subversion

    install_java_tools
    install_devops_tools

    echo Done
}

install_subversion() {
    echo "Installing subversion"
    if [ ! -d "/home/$USERNAME/.subversion" ]; then
        apt-get update -qq && apt-get-install subversion
        ln -s "$(pwd)/home/.subversion" "/home/$USERNAME/.subversion"
        chown $USERNAME:$USERNAME "/home/$USERNAME/.subversion"
    fi

    # setup merge script
    rm -f /usr/local/bin/mysvnmerge
    ln -s "$(pwd)/bin/mysvnmerge" /usr/local/bin/mysvnmerge
}

install_git() {
    echo "Installing git"
    # git is already installed, just configure

    # setup .gitconfig
    local gitconfig_file="/home/$USERNAME/.gitconfig"
    rm -f $gitconfig_file
    ln -s "$(pwd)/home/.gitconfig" $gitconfig_file
    chown $USERNAME:$USERNAME $gitconfig_file

    # setup merge script
    rm -f /usr/local/bin/mygitmerge
    ln -s "$(pwd)/bin/mygitmerge" /usr/local/bin/mygitmerge
}

install_vim() {
    echo "Installing vim"
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
    apt-get update -qq && apt-get-install tree python-pip python3-pip sshfs cifs-utils 
}

install_devops_tools() {
    install_ansible
    install_vagrant
    install_packer
    install_docker
}

install_java_tools() {
    echo "Installing java tools"
    install_oracle_java 8
    if ! program_exists ant; then
        apt-get-install ant ant-contrib maven
    fi
}

install_oracle_java() {
    echo "Installing java $1"
    apt-add-repository ppa:webupd8team/java -y
    echo oracle-java$1-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
    apt-get update -qq && apt-get-install oracle-java$1-installer oracle-java$1-set-default
}

install_packer() {
    echo "Installing packer"
    if ! program_exists packer; then
        local PACKER_VERSION="0.10.0"
        wget --progress=bar:force:noscroll --directory-prefix="/usr/local/bin/" "https://releases.hashicorp.com/packer/$PACKER_VERSION/packer_${PACKER_VERSION}_linux_amd64.zip"
        # -o tells unzip to overwrite existing files
        unzip -o "/usr/local/bin/packer_${PACKER_VERSION}_linux_amd64.zip" -d "/usr/local/bin/"
        rm "/usr/local/bin/packer_${PACKER_VERSION}_linux_amd64.zip"
    fi
}

install_ansible() {
    echo "Installing ansible"
    if ! program_exists ansible; then
        apt-add-repository ppa:ansible/ansible -y
        apt-get update -qq && apt-get-install ansible
        ! grep --quiet "export ANSIBLE_NOCOWS" && echo "export ANSIBLE_NOCOWS=1" >> "/home/$USERNAME/.bashrc"
    fi
}

install_vagrant() {
    echo "Installing vagrant"
    if ! program_exists vagrant; then
        apt-get update -qq && apt-get-install vagrant
    fi
}

install_docker() {
    echo "Installing docker-engine"
    # install docker-engine 
    if ! program_exists docker; then
        apt-key adv --keyserver "hkp://p80.pool.sks-keyservers.net:80" --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
        echo "deb https://apt.dockerproject.org/repo ubuntu-$(lsb_release -cs) main" > "/etc/apt/sources.list.d/docker.list"
        apt-get update -qq && apt-get-install linux-image-extra-$(uname -r) docker-engine
        if [ -z "$CI" ]; then
            # allow running docker without sudo
            usermod -aG docker $USERNAME
        fi
    fi

    # install docker-machine
    echo "Installing docker-machine"
    if ! program_exists docker-machine; then
        wget --progress=bar:force:noscroll "https://github.com/docker/machine/releases/download/v0.6.0/docker-machine-$(uname -s)-$(uname -m)" -O "/usr/local/bin/docker-machine"
        chmod +x /usr/local/bin/docker-machine
    fi

    # install docker-compose
    echo "Installing docker-compose"
    if ! program_exists docker-compose; then
        wget --progress=bar:force:noscroll "https://github.com/docker/compose/releases/download/1.6.2/docker-compose-$(uname -s)-$(uname -m)" -O "/usr/local/bin/docker-compose"
        chmod +x "/usr/local/bin/docker-compose"
    fi
}

program_exists() {
    hash "$1" 2>/dev/null
}

apt-get-install() {
    if [ -n "$CI" ]; then
        apt-get install -y --dry-run "$@"
    else
        apt-get install -y "$@"
    fi
}

check_root() {
    if [ "$(whoami)" != "root" ]; then
        echo "Must be root."
        exit 1
    fi
}

main
