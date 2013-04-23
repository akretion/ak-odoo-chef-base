# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'berkshelf/vagrant'

Vagrant::Config.run do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # The path to the Berksfile to use with Vagrant Berkshelf
  # config.berkshelf.berksfile_path = "./Berksfile"

  # An array of symbols representing groups of cookbook described in the Vagrantfile
  # to skip installing and copying to Vagrant's shelf.
  # config.berkshelf.only = []

  # An array of symbols representing groups of cookbook described in the Vagrantfile
  # to skip installing and copying to Vagrant's shelf.
  # config.berkshelf.except = []

#  config.vm.customize ["modifyvm", :id, "--cpus", 2]
#  config.vm.customize ["modifyvm", :id, "--memory", 1024]
      
  config.vm.host_name = "ak-openerp-base"

  config.vm.box = "precise32"
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"

  # Boot with a GUI so you can see the screen. (Default is headless)
  # config.vm.boot_mode = :gui

  # Assign this VM to a host-only network IP, allowing you to access it
  # via the IP. Host-only networks can talk to the host machine as well as
  # any other machines on the same network, but cannot be accessed (through this
  # network interface) by any external networks.
  config.vm.network :hostonly, "33.33.33.10"

  config.vm.forward_port 8069, 8169
  config.vm.forward_port 8169, 8269
  config.vm.forward_port 8269, 8369

  # Assign this VM to a bridged network, allowing you to connect directly to a
  # network using the host's network device. This makes the VM appear as another
  # physical device on your network.

  # config.vm.network :bridged

  # Forward a port from the guest to the host, which allows for outside
  # computers to access the VM, whereas host only networking does not.
  # config.vm.forward_port 80, 8080

  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder.
  # config.vm.share_folder "v-data", "/vagrant_data", "../data"

  config.ssh.max_tries = 40
  config.ssh.timeout   = 120
  
  #config.vm.share_folder("archive", "/opt/openerp/branch/", "/opt/openerp/branch/")
  #config.vm.share_folder("ssh", "~/.ssh", "~/.ssh")

  config.vm.provision :shell, :path => "install_chef.sh"
 
  config.vm.provision :chef_solo do |chef|
    chef.add_recipe 'ak-openerp-base::default'
    chef.json = {
        :postgresql => {:version => '9.2'},
#        :ak_tools => {:apt_packages_extra => ['libreoffice']},
        :openerp => {
          :super_user => {"unix_user" => "vagrant"},
          :prod => {"unix_user" => "vagrant"},
          :dev => {"unix_user" => "vagrant"},
#          :dev_servers => {:dev1 => user@host:path}
#          :demo_servers => {:demo1 => {:server => 'lp:~ocb/ocb-server/rs-ocb-70', :addons => 'lp:~ocb/ocb-addons/rs-ocb-70', :web => 'lp:ocb-web'}}
        },
      }
  end
end
