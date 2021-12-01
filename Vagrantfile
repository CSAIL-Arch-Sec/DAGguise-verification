# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.ssh.forward_x11 = true
  config.vm.synced_folder "./", "/DAGguise-verification"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "16384"
    vb.cpus = "8"
  end
  config.vm.provision :shell, path: "VagrantBootOnce.sh"
end
