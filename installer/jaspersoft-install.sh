#!/usr/bin/env bash

# Check for root privileges
if [ "$(whoami)" != "root" ]; then
	echo "Must be root."
	exit 1
fi

USERNAME=$SUDO_USER

chown $USERNAME:$USERNAME /home/$USERNAME/.ssh/config
chmod 600 /home/$USERNAME/.ssh/config

# jst
mkdir ~/src
cd ~/src
git clone https://github.com/rzhilkibaev/jst.git
sudo ~/src/jst/bin/install
