#!/usr/bin/env bash

# This is a plain bash script installer, it doesn't use ansible.

# Check for root privileges
if [ "$(whoami)" != "root" ]; then
	echo "Must be root."
	exit 1
fi

UBUNTU_CODENAME=trusty
USERNAME=$SUDO_USER

# Java
PACKAGES="oracle-java7-installer oracle-java8-installer oracle-java8-set-default"

# Virtualization
PACKAGES="$PACKAGES virtualbox-4.3 dkms lxc-docker cgroup-lite apparmor vagrant"

# SVC
PACKAGES="$PACKAGES git subversion mercurial kdiff3"

# Build tools
PACKAGES="$PACKAGES ant ant-contrib"
MAVEN_VERSION="3.2.5"
M2_HOME=/usr/local/maven

# Misc
PACKAGES="$PACKAGES vim vim-syntax-docker tree ansible curl python-pip python3-pip skype remmina remmina-plugin-rdp xrdp vino apt-file"

##################################################
# Prepare

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

# Skype
dpkg --add-architecture i386
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

pip install pjson

# Maven
mkdir -p $M2_HOME
wget -qO- http://apache.mirrors.lucidnetworks.net/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar --strip-components=1 -xzC $M2_HOME

##################################################
# Configure

# Docker
# allow non-sudo access
gpasswd -a $USERNAME docker
service docker restart
# orphaned volumes cleanup script
wget -q https://raw.githubusercontent.com/chadoe/docker-cleanup-volumes/master/docker-cleanup-volumes.sh -O /var/local/bin/docker-cleanup-volumes.sh
chmod +x /var/local/bin/docker-cleanup-volumes.sh

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
wget -q https://github.com/rzhilkibaev/dev-env/raw/master/installer/svn-kdiff3-wrapper -O /usr/bin/svn-kdiff3-wrapper
chmod +x /usr/bin/svn-kdiff3-wrapper
mkdir /home/$USERNAME/.subversion
cat > /home/$USERNAME/.subversion/config <<"EOL"
[helpers]
editor-cmd = vim
diff-cmd = /usr/bin/svn-kdiff3-wrapper.sh
diff3-cmd = /usr/bin/svn-kdiff3-wrapper.sh
merge-tool-cmd = /usr/bin/svn-kdiff3-wrapper.sh
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
call vundle#end()

" Put your non-Plugin stuff after this line

filetype plugin indent on

:set nowrap
:set tabstop=4 shiftwidth=4 expandtab
:set hidden
:set wildmenu

"XML folding
let g:xml_syntax_folding=1
autocmd FileType xml setlocal foldmethod=syntax

"Highlight current line and column
:set cursorline                                                                                                                                                                                                                               
:set cursorcolumn
:hi CursorLine   cterm=NONE ctermbg=black
:hi CursorColumn cterm=NONE ctermbg=black

" Toggle NERDTree
map <C-n> :NERDTreeToggle<CR>
EOL
chown $USERNAME:$USERNAME /home/$USERNAME/.vimrc
vim +PluginInstall +qall
chown -R $USERNAME:$USERNAME /home/$USERNAME/.vim

# Bash
echo "export M2_HOME=$M2_HOME" > /home/$USERNAME/.bashrc
cat >> /home/$USERNAME/.bashrc <<"EOL"
export PATH=$PATH:$M2_HOME/bin

# Show current directory in terminal window title
PROMPT_COMMAND='echo -ne "\033]0;`basename ${PWD}` ${PWD}\007"'

export ANSIBLE_NOCOWS=1

alias ll="ls -lAh --group-directories-first"
alias lll="ll --color=always | less -R"

docker-memory-usage(){
    for line in `docker ps | awk '{print $1}' | grep -v CONTAINER`; do docker ps | grep $line | awk '{printf $NF" "}' && echo $(( `cat /sys/fs/cgroup/memory/docker/$line*/memory.usage_in_bytes` / 1024 / 1024 ))MB ; done
}
EOL
chown $USERNAME:$USERNAME /home/$USERNAME/.bashrc

