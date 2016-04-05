# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    #config.vm.box = "MSchmidtEsd/xvivid64min"
    config.vm.box = "ubuntu/wily64"
    #config.vm.network "forwarded_port", guest: 5900, host: 5900 # vino
    #config.vm.network "forwarded_port", guest: 3389, host: 3389 # xrdp
    #config.vm.network "forwarded_port", guest: 4000, host: 4001 # nomachine
    config.vm.provision "shell", path: "setup.sh"
    #config.vm.provision "shell", path: "setup.sh", args: "container"
    #config.vm.provision "shell", path: "installer/rdp.sh"
    #config.vm.provider "virtualbox" do |v|
    #    v.gui = true
    #end

end
