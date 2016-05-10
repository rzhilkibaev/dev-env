#!/usr/bin/env bash

set -eo pipefail

SETUP_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function main() {
    
    configure_keyboard

    echo Done
}

configure_keyboard() {
    echo "Configuring keyboard"
    # map Caps Lock to Ctrl
    mkdir -p "~/.config/autostart"
    make_symlink "$SETUP_HOME/home/.config/autostart/xmodmap.desktop"  "~/.config/autostart/xmodmap.desktop"
    make_symlink "$SETUP_HOME/home/.xmodmaprc"  "~/.xmodmaprc"
    xmodmap "~/.xmodmaprc"
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
