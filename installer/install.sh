#!/usr/bin/env bash

cd /tmp

# install ansible
apt-get install software-properties-common -y
apt-add-repository ppa:ansible/ansible -y
apt-get update
apt-get install ansible -y

# install ansible roles
ansible-galaxy install smola.java
ansible-galaxy install groover.maven
ansible-galaxy install kost.virtualbox

# install git
apt-get install git -y

# get playbook
git git@github.com:rzhilkibaev/dev-env.git

# run playbook
cd dev-env/ansible-playbook

ansible-playbook -i tests/inventory site.yml --connection=local --sudo

