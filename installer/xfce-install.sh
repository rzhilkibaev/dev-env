#!/usr/bin/env bash

set -e
set -o pipefail

# Check for root privileges
if [ "$(whoami)" != "root" ]; then
	echo "Must be root."
	exit 1
fi

USERNAME=$SUDO_USER

# set global keyboard shortcuts
wget -q https://github.com/rzhilkibaev/dev-env/raw/master/installer/xfce4-keyboard-shortcuts.default.xml -O /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
wget -q https://github.com/rzhilkibaev/dev-env/raw/master/installer/xfce4-keyboard-shortcuts.mint.xml -O /usr/share/mint-configuration-xfce/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
mkdir -p /home/${USERNAME}/.config/xfce4/xfconf/xfce-perchannel-xml 
wget -q https://github.com/rzhilkibaev/dev-env/raw/master/installer/xfce4-keyboard-shortcuts.xml -O /home/${USERNAME}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml

echo "Done"
