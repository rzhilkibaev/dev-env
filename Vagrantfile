# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.vm.define "ubuntu" do |ubuntu|
        ubuntu.vm.box = "ubuntu/xenial64"
        # see https://github.com/mitchellh/vagrant/issues/1673#issuecomment-28287711
        ubuntu.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
    end
    config.vm.define "fedora" do |fedora|
        fedora.vm.box = "fedora/26-cloud-base"
    end

    # I use inline and not path because the script reads from other scripts/directories.
    # When using path Vagrant will copy the script into /tmp and run it from there, making it impossible to access any additional files.
    config.vm.provision "shell", inline: "/vagrant/setup.sh"

    #config.vm.box = "fedora/26-cloud-base"
    #config.vm.network "forwarded_port", guest: 5900, host: 5900 # vino
    #config.vm.network "forwarded_port", guest: 3389, host: 3389 # xrdp
    #config.vm.network "forwarded_port", guest: 4000, host: 4001 # nomachine
end
