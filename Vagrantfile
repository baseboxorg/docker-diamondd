# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX_NAME = ENV["BOX_NAME"] || "box-cutter/ubuntu1404-docker"
BOX_MEMORY = ENV["BOX_MEMORY"] || "2048"
DMD_DOMAIN = ENV["DMD_DOMAIN"] || "dmd.dev"
DMD_IP = ENV["DMD_IP"] || "10.0.0.10"
CONNECTED_PORT = (ENV["CONNECTED_PORT"] || '17771').to_i
RPC_PORT = (ENV["RPC_PORT"] || '17772').to_i
PUBLIC_KEY_PATH = "#{Dir.home}/.ssh/openbase-key.pub"

Vagrant::configure("2") do |config|
  config.ssh.forward_agent = true

  config.vm.box = BOX_NAME



  config.vm.provider :vmware_fusion do |v|
    v.vmx["memsize"] = BOX_MEMORY
  end

  config.vm.define "empty", autostart: false

  config.vm.define "dmd", primary: true do |vm|
    vm.vm.synced_folder File.dirname(__FILE__), "/root/dmd"
    vm.vm.network :forwarded_port, guest: 17771, host: CONNECTED_PORT
    vm.vm.network :forwarded_port, guest: 17772, host: RPC_PORT
    vm.vm.hostname = "#{DMD_DOMAIN}"
    vm.vm.network :private_network, ip: DMD_IP
  end



  if Pathname.new(PUBLIC_KEY_PATH).exist?
    config.vm.provision :file, source: PUBLIC_KEY_PATH, destination: '/tmp/id_rsa.pub'
    config.vm.provision :shell, :inline => "rm -f /root/.ssh/authorized_keys && mkdir -p /root/.ssh && sudo cp /tmp/id_rsa.pub /root/.ssh/authorized_keys"
  end
end
