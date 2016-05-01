#!/usr/bin/env bash
# sets up RDP server with xrdp and vino

set -e
set -o pipefail

USERNAME=$SUDO_USER

apt-get update
apt-get install -y vino xrdp

# configure vino
gsettings set org.gnome.Vino enabled true
gsettings set org.gnome.Vino prompt-enabled false
gsettings set org.gnome.Vino require-encryption false

# autostart vino
mkdir -p /home/$USERNAME/.config/autostart
cat > /home/$USERNAME/.config/autostart/vino-server.desktop <<"EOL"
[Desktop Entry]
Encoding=UTF-8
Version=0.9.4
Type=Application
Name=vino-server
Comment=vino-server
Exec=/usr/lib/vino/vino-server
OnlyShowIn=XFCE;
StartupNotify=false
Terminal=false
Hidden=false                                                                                                                                                                                     
EOL
chown -R $USERNAME:$USERNAME /home/$USERNAME/.config/autostart

# configure xrdp
cat > /etc/xrdp/xrdp.ini  <<"EOL"
[globals]
bitmap_cache=yes
bitmap_compression=yes
port=3389
crypt_level=low
channel_code=1
max_bpp=24

[xrdp1]
name=vino
lib=libvnc.so
username=
password=
ip=127.0.0.1
port=5900
EOL
