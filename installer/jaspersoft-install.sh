#!/usr/bin/env bash

# Check for root privileges
if [ "$(whoami)" != "root" ]; then
	echo "Must be root."
	exit 1
fi

USERNAME=$SUDO_USER

# ssh
cat > /home/$USERNAME/.ssh/config <<"EOL"
Host falcon.jaspersoft.com
    HostName falcon.jaspersoft.com
    IdentityFile ~/.ssh/<private_key>

EOL
chown $USERNAME:$USERNAME /home/$USERNAME/.ssh/config
chmod 600 /home/$USERNAME/.ssh/config
