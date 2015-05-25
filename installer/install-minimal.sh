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
echo "Installing Vagrant"
wget -q https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.2_x86_64.deb -O /tmp/vagrant.deb
dpkg -i /tmp/vagrant.deb
rm -f /tmp/vagrant.deb

# Maven
echo "Installing Maven"
MAVEN_VERSION="3.2.5"
M2_HOME=/usr/local/maven
mkdir -p $M2_HOME
wget -qO- http://apache.mirrors.lucidnetworks.net/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar --strip-components=1 -xzC $M2_HOME

##################################################
# Configure
echo "Configuring"

# Git
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

# Subversion
mkdir /home/$USERNAME/.subversion
cat > /home/$USERNAME/.subversion/config <<"EOL"
[helpers]
editor-cmd = vim
EOL
chown -R $USERNAME:$USERNAME /home/$USERNAME/.subversion

# Vim
git clone https://github.com/gmarik/Vundle.vim.git /home/$USERNAME/.vim/bundle/Vundle.vim

cat > /home/$USERNAME/.vimrc <<"EOL"
set nocompatible                                        " not compatible with vi, required by Vundle
filetype off                                            " required by Vundle

" set the runtime path to include Vundle
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Plugin 'chase/vim-ansible-yaml'
Plugin 'fholgado/minibufexpl.vim' 
Plugin 'docker/docker' , {'rtp': '/contrib/syntax/vim/'}
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
:hi CursorLine   cterm=NONE ctermbg=black
:hi CursorColumn cterm=NONE ctermbg=black
EOL
chown $USERNAME:$USERNAME /home/$USERNAME/.vimrc
vim +PluginInstall +qall
chown -R $USERNAME:$USERNAME /home/$USERNAME/.vim

# Bash
echo "export M2_HOME=$M2_HOME" >> /home/$USERNAME/.bashrc
cat >> /home/$USERNAME/.bashrc <<"EOL"
export PATH=$PATH:$M2_HOME/bin

# Show current directory in terminal window title
PROMPT_COMMAND='echo -ne "\033]0;`basename ${PWD}` ${PWD}\007"'

export ANSIBLE_NOCOWS=1

alias ll="ls -lAh --group-directories-first"
alias lll="ll --color=always | less -R"

alias docker-remove-untagged-images='docker rmi $(docker images -q --filter "dangling=true")'

docker-memory-usage(){
    for line in `docker ps | awk '{print $1}' | grep -v CONTAINER`; do docker ps | grep $line | awk '{printf $NF" "}' && echo $(( `cat /sys/fs/cgroup/memory/docker/$line*/memory.usage_in_bytes` / 1024 / 1024 ))MB ; done
}
EOL
chown $USERNAME:$USERNAME /home/$USERNAME/.bashrc

echo "Done"
