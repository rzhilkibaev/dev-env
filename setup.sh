#!/usr/bin/env bash

# Usage: setup.sh
#
# Guidelines
# - This script is executed once in a few months, execution speed doesn't matter much. Readability does.
# - Each install_* function should be independent.

#set -x
set -eo pipefail

SETUP_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
USERNAME=$SUDO_USER
USERHOME=/home/$USERNAME
export DEBIAN_FRONTEND=noninteractive

function main() {
    
    check_root

    install_basic_tools

    install_oh_my_zh
    install_vim
    install_neovim
    install_git
    install_subversion

    install_java_tools
    install_devops_tools
    install_frontend_tools

    echo Done
}

install_oh_my_zh() {
    echo "Installing oh my zh"
    apt-get-install zsh
    chsh -s /bin/zsh
    git clone "https://github.com/robbyrussell/oh-my-zsh.git" "$USERHOME/.oh-my-zsh"
    cp "$USERHOME/.oh-my-zsh/templates/zshrc.zsh-template" "$USERHOME/.zshrc"
    install_powerline_fonts
    # install powerlevel9k theme
    git clone "https://github.com/bhilburn/powerlevel9k.git" "$USERHOME/.oh-my-zsh/custom/themes/powerlevel9k"
    # configure oh-my-zsh
    sed -i "1iPOWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(virtualenv vcs background_jobs)" "$USERHOME/.zshrc"
    sed -i "1iPOWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir)" "$USERHOME/.zshrc"
    sed -i "1iDEFAULT_USER=$USERNAME" "$USERHOME/.zshrc"
    sed -i "1iexport TERM=xterm-256color" "$USERHOME/.zshrc"
    sed -i "/^ZSH_THEME=.*/c\ZSH_THEME=powerlevel9k\/powerlevel9k" "$USERHOME/.zshrc"
    chown -R $USERNAME:$USERNAME "$USERHOME/.oh-my-zsh"
    chown $USERNAME:$USERNAME "$USERHOME/.zshrc"
}

install_subversion() {
    echo "Installing subversion"
    apt-get-install subversion
    make_symlink "$SETUP_HOME/home/.subversion/config" "$USERHOME/.subversion/config"
    chown $USERNAME:$USERNAME "$USERHOME/.subversion"
    # setup merge script
    make_symlink "$SETUP_HOME/bin/mysvnmerge" /usr/local/bin/mysvnmerge
    make_symlink "$SETUP_HOME/bin/mysvndiff" /usr/local/bin/mysvndiff
}

install_git() {
    echo "Installing git"
    # git is already installed, just configure
    # setup .gitconfig
    make_symlink "$SETUP_HOME/home/.gitconfig" "$USERHOME/.gitconfig"
    chown $USERNAME:$USERNAME "$USERHOME/.gitconfig"
    # setup merge script
    make_symlink "$SETUP_HOME/bin/mygitmerge" /usr/local/bin/mygitmerge
    apt-get-install tig
}

install_vim() {
    echo "Installing vim"
    # vim is already installed, just configure

    # install dein plugin manager
    local dein_dir="$USERHOME/.vim/dein/repos/github.com/Shougo/dein.vim"
    if [ ! -d "$dein_dir" ]; then
        mkdir -p "$dein_dir"
        git clone "https://github.com/Shougo/dein.vim.git"  "$dein_dir"
        chown -R $USERNAME:$USERNAME "$USERHOME/.vim"
    fi
    make_symlink "$SETUP_HOME/home/.vimrc" "$USERHOME/.vimrc"
    chown -h $USERNAME:$USERNAME "$USERHOME/.vimrc"
    echo "installing fonts"
    install_powerline_fonts
}

install_neovim() {
    echo "Installing neovim"
    add-apt-repository -y ppa:neovim-ppa/unstable
    # xsel enables system clipboard
    apt-get-install neovim xsel

    # install dein plugin manager
    local dein_dir="$USERHOME/.config/nvim/dein/repos/github.com/Shougo/dein.vim"
    if [ ! -d "$dein_dir" ]; then
        mkdir -p "$dein_dir"
        git clone "https://github.com/Shougo/dein.vim.git"  "$dein_dir"
        chown -R $USERNAME:$USERNAME "$USERHOME/.config/nvim"
    fi
    make_symlink "$SETUP_HOME/home/.config/nvim/init.vim" "$USERHOME/.config/nvim/init.vim"
    chown -h $USERNAME:$USERNAME "$USERHOME/.config/nvim/init.vim"
    echo "installing fonts"
    install_powerline_fonts
}

install_powerline_fonts() {
    # install powerline fonts
    local font_dir="$USERHOME/.local/share/fonts"
    mkdir -p $font_dir
    cd $font_dir
    # install font DejaVu Sans Mono
    wget --timestamping --progress=bar:force:noscroll "https://github.com/powerline/fonts/raw/master/DejaVuSansMono/DejaVu%20Sans%20Mono%20Bold%20Oblique%20for%20Powerline.ttf"
    wget --timestamping --progress=bar:force:noscroll "https://github.com/powerline/fonts/raw/master/DejaVuSansMono/DejaVu%20Sans%20Mono%20Bold%20for%20Powerline.ttf"
    wget --timestamping --progress=bar:force:noscroll "https://github.com/powerline/fonts/raw/master/DejaVuSansMono/DejaVu%20Sans%20Mono%20Oblique%20for%20Powerline.ttf"
    wget --timestamping --progress=bar:force:noscroll "https://github.com/powerline/fonts/raw/master/DejaVuSansMono/DejaVu%20Sans%20Mono%20for%20Powerline.ttf"
    chown -R $USERNAME:$USERNAME "$USERHOME/.local"
    fc-cache -vf $font_dir
}

install_basic_tools() {
    apt-get-install tree python-pip python3-pip sshfs cifs-utils htop
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
    apt-get-install oracle-java$1-installer oracle-java$1-set-default
}

install_packer() {
    echo "Installing packer"
    if ! program_exists packer; then
        local PACKER_VERSION="0.10.0"
        wget --timestamping --progress=bar:force:noscroll --directory-prefix="/usr/local/bin/" "https://releases.hashicorp.com/packer/$PACKER_VERSION/packer_${PACKER_VERSION}_linux_amd64.zip"
        # -o tells unzip to overwrite existing files
        unzip -o "/usr/local/bin/packer_${PACKER_VERSION}_linux_amd64.zip" -d "/usr/local/bin/"
        rm "/usr/local/bin/packer_${PACKER_VERSION}_linux_amd64.zip"
    fi
}

install_ansible() {
    echo "Installing ansible"
    if ! program_exists ansible; then
        apt-add-repository ppa:ansible/ansible -y
        apt-get-install ansible
        ! grep --quiet "export ANSIBLE_NOCOWS" && echo "export ANSIBLE_NOCOWS=1" >> "$USERHOME/.bashrc"
    fi
}

install_vagrant() {
    echo "Installing vagrant"
    if ! program_exists vagrant; then
        apt-get-install vagrant
    fi
}

install_docker() {
    echo "Installing docker-engine"
    # install docker-engine 
    if ! program_exists docker; then
        apt-key adv --keyserver "hkp://p80.pool.sks-keyservers.net:80" --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
        echo "deb https://apt.dockerproject.org/repo ubuntu-$(lsb_release -cs) main" > "/etc/apt/sources.list.d/docker.list"
        apt-get-install linux-image-extra-$(uname -r) docker-engine
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
        wget --progress=bar:force:noscroll "https://github.com/docker/compose/releases/download/1.7.0/docker-compose-$(uname -s)-$(uname -m)" -O "/usr/local/bin/docker-compose"
        chmod +x "/usr/local/bin/docker-compose"
    fi
}

install_frontend_tools() {
    echo "Installing nodejs"
    wget -qO- https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
    echo "deb https://deb.nodesource.com/node_4.x $(lsb_release -cs) main" > /etc/apt/sources.list.d/nodesource.list
    echo "deb-src https://deb.nodesource.com/node_4.x $(lsb_release -cs) main" >> /etc/apt/sources.list.d/nodesource.list
    apt-get-install nodejs
    npm install npm -g
}

program_exists() {
    hash "$1" 2>/dev/null
}

apt-get-install() {
    apt-get update -qq
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

make_symlink() {
    local target="$1"
    local link_name="$2"

    # ensure link path (won't complain if exists)
    mkdir -p $(dirname "$link_name")
    rm -f "$link_name"
    ln -s "$target" "$link_name"
}

main
