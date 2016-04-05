#!/usr/bin/env bash

# Usage: setup.sh
#
# Guidelines
# - This script is executed once in a few months, execution speed doesn't matter much. Readability does.
# - Each install_* and configure_* function should be independent.

#set -x
set -eo pipefail

MAVEN_VERSION="3.3.9"
VAGRANT_VERSION="1.7.4"
USERNAME=$SUDO_USER
export DEBIAN_FRONTEND=noninteractive

echo "Hi"
exit 0

function main() {
    
    check_root

    install_oracle_java_7

}

function check_root() {
    if [ "$(whoami)" != "root" ]; then
        echo "Must be root."
        exit 1
    fi
}

install_oracle_java_7() {
    apt-add-repository ppa:webupd8team/java -y
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
    apt-get update && apt-get install -y oracle-java7-installer oracle-java7-set-default
}

install_oracle_java_8() {
    apt-add-repository ppa:webupd8team/java -y
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
    apt-get update && apt-get install -y oracle-java8-installer oracle-java8-set-default
}

install_ansible() {
    apt-add-repository ppa:ansible/ansible -y
    apt-get update && apt-get install -y ansible
}

install_maven() {
    M2_HOME=/usr/local/maven
    mkdir -p $M2_HOME
    wget -qO- http://apache.mirrors.lucidnetworks.net/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar --strip-components=1 -xzC $M2_HOME
}

function setup_container() {

    install_oracle_java_7
    install_oracle_java_8
    install_ansible
    install_maven

    # Install
    apt-get update && apt-get install -y \
        git subversion vim tree curl python-pip python3-pip sshfs cifs-utils \
        ant ant-contrib

    # Configure Git
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

    # Configure Subversion
    #wget -q https://github.com/rzhilkibaev/dev-env/raw/master/installer/svn-diff-vimdiff.sh -O /usr/bin/svn-diff-vimdiff.sh
    #chmod +x /usr/bin/svn-diff-vimdiff.sh
    #wget -q https://github.com/rzhilkibaev/dev-env/raw/master/installer/svn-merge-tool-cmd-vimdiff.sh -O /usr/bin/svn-merge-tool-cmd-vimdiff.sh 
    #chmod +x /usr/bin/svn-merge-tool-cmd-vimdiff.sh
    mkdir -p /home/$USERNAME/.subversion
cat > /home/$USERNAME/.subversion/config <<"EOL"
[helpers]
editor-cmd = vim
diff-cmd = /usr/bin/svn-diff-vimdiff.sh
merge-tool-cmd = /usr/bin/svn-merge-tool-cmd-vimdiff.sh
EOL
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.subversion

    # Configure Vim
    if [ ! -d /home/$USERNAME/.vim/bundle/Vundle.vim ]; then
        git clone https://github.com/gmarik/Vundle.vim.git /home/$USERNAME/.vim/bundle/Vundle.vim
    fi

cat > /home/$USERNAME/.vimrc <<"EOL"
set nocompatible                                        " not compatible with vi, required by Vundle
filetype off                                            " required by Vundle

" set the runtime path to include Vundle
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Plugin 'chase/vim-ansible-yaml'
Plugin 'fholgado/minibufexpl.vim' 
Plugin 'ekalinin/Dockerfile.vim'
call vundle#end()

" Put your non-Plugin stuff after this line

filetype plugin indent on

:set nowrap
:set tabstop=4 shiftwidth=4 expandtab
:set hidden
:set wildmenu
:set number

"XML folding
let g:xml_syntax_folding=1
autocmd FileType xml setlocal foldmethod=syntax

"Highlight current line and column
:set cursorline                                                                                                                                                                                                                               
:set cursorcolumn
:hi CursorLine   cterm=NONE ctermbg=255
:hi CursorColumn cterm=NONE ctermbg=255

"Use CLIPBOARD for yank, put, etc...
:set clipboard=unnamedplus

"Highlight all occurences when searching
:set hlsearch
EOL
    chown $USERNAME:$USERNAME /home/$USERNAME/.vimrc
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.vim

    # Configure Bash
    if ! grep -q "# dev-env managed section begin" /home/$USERNAME/.bashrc; then
        echo "# dev-env managed section begin" >> /home/$USERNAME/.bashrc
        echo "export M2_HOME=$M2_HOME" >> /home/$USERNAME/.bashrc
cat >> /home/$USERNAME/.bashrc <<"EOL"
export PATH=$PATH:$M2_HOME/bin

# Show current directory in terminal window title
PROMPT_COMMAND='echo -ne "\033]0;`basename ${PWD}` ${PWD}\007"'

export ANSIBLE_NOCOWS=1

alias ll="ls -lAh --group-directories-first"
alias lll="ll --color=always | less -R"

# Enable 256 colors in terminal
export TERM=xterm-256color

# dev-env managed section end
EOL
    fi
    chown $USERNAME:$USERNAME /home/$USERNAME/.bashrc
}

function setup_vmheadless() {
    # Install Docker
    wget -qO- https://get.docker.com/ | sh
    # Allow non-sudo access
    gpasswd -a $USERNAME docker
    service docker restart

    # Install Vagrant
    echo "Downloading Vagrant..."
    wget --no-verbose https://dl.bintray.com/mitchellh/vagrant/vagrant_${VAGRANT_VERSION}_x86_64.deb
    dpkg -i vagrant_${VAGRANT_VERSION}_x86_64.deb
}

function setup_vmgui() {
    # Prepare Skype
    dpkg --add-architecture i386
    # set DISTRIB_CODENAME
    source /etc/lsb-release
    if [ "$DISTRIB_CODENAME" = "rafaela" ] || [ "$DISTRIB_CODENAME" = "rebecca" ]; then
        DISTRIB_CODENAME=trusty
    fi
    apt-add-repository "deb http://archive.canonical.com/ $DISTRIB_CODENAME partner"
    # Install
    apt-get update && apt-get install -y skype kdiff3 meld remmina remmina-plugin-rdp xrdp vino
    # Configure Git
cat > /home/$USERNAME/.gitconfig <<"EOL"
[push]
        default = simple
[diff]
        tool = kdiff3
[merge]
        tool = kdiff3
[difftool]
        prompt = false
EOL
    chown $USERNAME:$USERNAME /home/$USERNAME/.gitconfig
    # Configure Subversion
cat > /home/$USERNAME/.subversion/config <<"EOL"
[helpers]
editor-cmd = vim
diff-cmd = /usr/bin/svn-kdiff3-wrapper.sh
diff3-cmd = /usr/bin/svn-kdiff3-wrapper.sh
merge-tool-cmd = /usr/bin/svn-kdiff3-wrapper.sh
EOL
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.subversion
    # Configure gvim
    echo '"Resize gvim window'        > /home/$USERNAME/.gvimrc
    echo ':set lines=60 columns=200' >> /home/$USERNAME/.gvimrc
}

function setup_physical() {
    # Install VirtualBox
    wget -q -O - https://www.virtualbox.org/download/oracle_vbox.asc | apt-key add -
    echo "deb http://download.virtualbox.org/virtualbox/debian $DISTRIB_CODENAME contrib" > /etc/apt/sources.list.d/virtualbox.list
    apt-get update && apt-get install -y dkms virtualbox-5.0
}

main
