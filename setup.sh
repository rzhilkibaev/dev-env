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

main() {

    check_root

#    install_basic_tools
#
#    install_oh_my_zh
#    install_vim
#    install_nvim
#    install_git
#    install_subversion
#
#    install_java_tools
    install_devops_tools
#    install_frontend_tools

    echo Done
}

install_oh_my_zh() {
    echo "Installing oh my zh"
    apt-get-install zsh
    chsh -s /bin/zsh
    if [ ! -d "$USERHOME/.oh-my-zsh" ]; then
        git clone "https://github.com/robbyrussell/oh-my-zsh.git" "$USERHOME/.oh-my-zsh"
    fi
    install_powerline_fonts
    # install powerlevel9k theme
    if [ ! -d "$USERHOME/.oh-my-zsh/custom/themes/powerlevel9k" ]; then
        git clone "https://github.com/bhilburn/powerlevel9k.git" "$USERHOME/.oh-my-zsh/custom/themes/powerlevel9k"
    fi
    chown -R $USERNAME:$USERNAME "$USERHOME/.oh-my-zsh"
    make_symlink "$SETUP_HOME/home/.zshrc" "$USERHOME/.zshrc"
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
    make_symlink "$SETUP_HOME/home/.tigrc" "$USERHOME/.tigrc"
    chown $USERNAME:$USERNAME "$USERHOME/.tigrc"
}

install_vim() {
    echo "Installing vim"
    # install vim with clipboard and python support
    apt-get-install vim-gtk

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

install_nvim() {
    echo "Installing neovim"
    add-apt-repository ppa:neovim-ppa/unstable -y
    # also install xsel for clipboard support
    apt-get-install neovim xsel
    sudo pip install neovim
    sudo pip3 install neovim
    sudo pip install jedi

    mkdir -p "$USERHOME/.config/nvim"
    make_symlink "$SETUP_HOME/home/.config/nvim/init.vim" "$USERHOME/.config/nvim/init.vim"
    chown -h $USERNAME:$USERNAME "$USERHOME/.config/nvim"
    install_powerline_fonts
}

install_powerline_fonts() {
    echo "installing Powerline fonts"
    # install powerline fonts
    local font_dir="$USERHOME/.local/share/fonts"
    mkdir -p $font_dir
    cd $font_dir
    # install font DejaVu Sans Mono
    wget -q --timestamping --progress=bar:force:noscroll "https://github.com/powerline/fonts/raw/master/DejaVuSansMono/DejaVu%20Sans%20Mono%20Bold%20Oblique%20for%20Powerline.ttf"
    wget -q --timestamping --progress=bar:force:noscroll "https://github.com/powerline/fonts/raw/master/DejaVuSansMono/DejaVu%20Sans%20Mono%20Bold%20for%20Powerline.ttf"
    wget -q --timestamping --progress=bar:force:noscroll "https://github.com/powerline/fonts/raw/master/DejaVuSansMono/DejaVu%20Sans%20Mono%20Oblique%20for%20Powerline.ttf"
    wget -q --timestamping --progress=bar:force:noscroll "https://github.com/powerline/fonts/raw/master/DejaVuSansMono/DejaVu%20Sans%20Mono%20for%20Powerline.ttf"
    chown -R $USERNAME:$USERNAME "$USERHOME/.local"
    fc-cache -vf $font_dir
}

install_basic_tools() {
    echo "Installing basic tools"
    # use gnome-terminal supports true color, terminator doesn't
    apt-get-install tree python-pip python3-pip sshfs cifs-utils htop gnome-terminal vifm
    make_symlink "$SETUP_HOME/bin/f" "/usr/local/bin/f"
    make_symlink "$SETUP_HOME/bin/pack" "/usr/local/bin/pack"
    make_symlink "$SETUP_HOME/bin/unpack" "/usr/local/bin/unpack"
    mkdir -p "$USERHOME/.vifm"
    make_symlink "$SETUP_HOME/home/.vifm/vifmrc" "$USERHOME/.vifm/vifmrc"
    chown -R $USERNAME:$USERNAME "$USERHOME/.vifm"
}

install_devops_tools() {
#    install_ansible
#    install_vagrant
#    install_packer
    install_docker
#    install_terraform
}

install_java_tools() {
    echo "Installing java tools"
    install_oracle_java 8
    install_ant
    install_gradle
}

install_ant() {
    if ! program_exists ant; then
        apt-get-install ant ant-contrib maven
    fi }

install_gradle() {
    make_symlink "$SETUP_HOME/bin/gradle" "/usr/local/bin/gradle"
}

install_oracle_java() {
    echo "Installing java $1"
    apt-add-repository ppa:webupd8team/java -y
    echo oracle-java$1-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
    apt-get-install oracle-java$1-installer oracle-java$1-set-default
}

install_packer() {
    echo "Installing packer"
    local PACKER_VERSION="0.10.1"
    wget --timestamping --progress=bar:force:noscroll --directory-prefix="/usr/local/bin/" "https://releases.hashicorp.com/packer/$PACKER_VERSION/packer_${PACKER_VERSION}_linux_amd64.zip"
    # -o tells unzip to overwrite existing files
    unzip -o "/usr/local/bin/packer_${PACKER_VERSION}_linux_amd64.zip" -d "/usr/local/bin/"
    rm "/usr/local/bin/packer_${PACKER_VERSION}_linux_amd64.zip"
}

install_ansible() {
    echo "Installing ansible"
    if ! program_exists ansible; then
        apt-add-repository ppa:ansible/ansible -y
        apt-get-install ansible
        ! grep --quiet "export ANSIBLE_NOCOWS" "$USERHOME/.bashrc" && echo "export ANSIBLE_NOCOWS=1" >> "$USERHOME/.bashrc"
    fi
}

install_vagrant() {
    echo "Installing vagrant"
    if ! program_exists vagrant; then
        apt-get-install vagrant
    fi
}

install_terraform() {
    echo "Installing terraform"
    local TERRAFORM_VERSION="0.7.5"
    local TERRAFROM_ZIP=terraform_${TERRAFORM_VERSION}_linux_amd64.zip
    wget --timestamping --progress=bar:force:noscroll --directory-prefix="/usr/local/bin/" "https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/$TERRAFROM_ZIP"
    # -o tells unzip to overwrite existing files
    unzip -o "/usr/local/bin/$TERRAFROM_ZIP" -d "/usr/local/bin/"
    rm "/usr/local/bin/$TERRAFROM_ZIP"
}

install_docker() {
    echo "Installing docker-engine"
    # install docker-engine
#    if ! program_exists docker; then
#        apt-key adv --keyserver "hkp://p80.pool.sks-keyservers.net:80" --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
#        echo "deb https://apt.dockerproject.org/repo ubuntu-$(lsb_release -cs) main" > "/etc/apt/sources.list.d/docker.list"
#        apt-get-install linux-image-extra-$(uname -r) docker-engine
#        if [ -z "$CI" ]; then
#            # allow running docker without sudo
#            usermod -aG docker $USERNAME
#        fi
#    fi

    # install docker-machine
    echo "Installing docker-machine"
    wget --progress=bar:force:noscroll "https://github.com/docker/machine/releases/download/v0.8.2/docker-machine-$(uname -s)-$(uname -m)" -O "/usr/local/bin/docker-machine"
    chmod +x /usr/local/bin/docker-machine

#    # install docker-compose
#    echo "Installing docker-compose"
#    wget --progress=bar:force:noscroll "https://github.com/docker/compose/releases/download/1.7.1/docker-compose-$(uname -s)-$(uname -m)" -O "/usr/local/bin/docker-compose"
#    chmod +x "/usr/local/bin/docker-compose"
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
