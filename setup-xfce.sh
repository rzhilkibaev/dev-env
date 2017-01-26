#!/usr/bin/env bash

set -eo pipefail

SETUP_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function main() {

    # this doesn't seem to work, commenting out for now
    #configure_keyboard 

    configure_taskbar

    echo Done
}

configure_keyboard() {
    echo "Configuring keyboard"
    # map Caps Lock to Ctrl
    mkdir -p "~/.config/autostart"
    make_symlink "$SETUP_HOME/home/.config/autostart/xmodmap.desktop"  "$HOME/.config/autostart/xmodmap.desktop"
    make_symlink "$SETUP_HOME/home/.xmodmaprc"  "$HOME/.xmodmaprc"
    xmodmap "$HOME/.xmodmaprc"
}

configure_taskbar() {
    echo "Configuring taskbar"
    mkdir -p "~/.config/autostart"
    # a hack to fix taskbar buttons on multiple monitors
    # https://forum.xfce.org/viewtopic.php?pid=32007#p32007
    make_symlink "$SETUP_HOME/home/.config/autostart/reload-taskbar.desktop"  "$HOME/.config/autostart/reload-taskbar.desktop"
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
