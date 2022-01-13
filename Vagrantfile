# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

# Intended to test the "install-packages.sh" provisioning script
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "ubuntu/focal64"

  config.vm.provision "shell", path: "./run_once_install-packages.sh", privileged: false

end
