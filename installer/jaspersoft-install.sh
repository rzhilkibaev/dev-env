#!/usr/bin/env bash

# run common installer
wget -qO- https://github.com/rzhilkibaev/dev-env/raw/master/installer/install.sh | bash

PACKAGES="jenkins oracle-java7-set-default"

PORT_JENKINS=10000

##################################################
# Prepare

# Jenkins
wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
echo "deb http://pkg.jenkins-ci.org/debian binary/" > /etc/apt/sources.list.d/jenkins.list

apt-get update

##################################################
# Install

apt-get install $PACKAGES -y

##################################################
# Configure

# Docker
# allow non-sudo access for jenkins
gpasswd -a jenkins docker
service docker restart
# allow api, add company dns, add local insecure registry
sed -i -e 's/DOCKER_OPTS=/DOCKER_OPTS="--dns 172.17.1.217 --dns 172.17.1.235 --dns 8.8.8.8 --dns 8.8.4.4 -H tcp://127.0.0.1:2375 -H unix:///var/run/docker.sock --insecure-registry 172.17.8.128:5000' #/g" /etc/default/docker

# Jenkins
# listen on $PORT_JENKINS
sed -i -e "s/HTTP_PORT=8080/HTTP_PORT=$PORT_JENKINS #/g" /etc/default/jenkins
service jenkins restart

# Docker Registry
docker pull registry
cat > /etc/init/docker-registry.conf <<EOF
description "Docker registry"

start on filesystem

script
	docker run -p 5000:5000 registry
end script
EOF
# enable autocomplete
ln -s /etc/init/docker-registry.conf /etc/init.d/docker-registry
