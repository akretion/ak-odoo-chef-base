if node[:platform_version].to_f < 11.10 #installs bzr 2.3 to be able to commit on stacked branches, see https://bugs.launchpad.net/bzr/+bug/375013

  apt_repository "bzr-beta" do
    uri "http://ppa.launchpad.net/bzr/beta/ubuntu"
    distribution node['lsb']['codename']
    components ["main"]
    action :add
    notifies :run, "execute[apt-get update-bzr]", :immediately
  end

  execute "apt-get update-bzr" do
    command "apt-get update"
    action :nothing
    notifies :upgrade, "package[bzr]", :immediately
  end

  package "bzr" do
    action :nothing
    options "--force-yes"
    notifies :upgrade, "package[bzrtools]", :immediately
  end

  package "bzrtools" do
    action :nothing
    options "--force-yes"
  end

else
  package "bzr"
end


user node[:openerp][:dev][:unix_user] do
  comment "OpenERP File User"
  gid node[:openerp][:group_unix]
  home "/home/#{node[:openerp][:dev][:unix_user]}"
  supports :manage_home => true
  shell "/bin/bash"
end

directory "/home/#{node[:openerp][:dev][:unix_user]}/.bazaar" do
  owner node[:openerp][:dev][:unix_user]
  group node[:openerp][:group_unix]
  action :create
end

template "/home/#{node[:openerp][:dev][:unix_user]}/.bazaar/bazaar.conf" do
  owner node[:openerp][:dev][:unix_user]
  group node[:openerp][:group_unix]
  source "bazaar.conf.erb"
  action :create_if_missing
end

directory "/home/#{node[:openerp][:dev][:unix_user]}/.bazaar/plugins" do
  owner node[:openerp][:dev][:unix_user]
  group node[:openerp][:group_unix]
  mode "0755"
  action :create
end

execute "bzr branch lp:bzr-push-and-update /home/#{node[:openerp][:dev][:unix_user]}/.bazaar/plugins/push_and_update" do
  creates "/home/#{node[:openerp][:dev][:unix_user]}/.bazaar/plugins/push_and_update"
  environment 'USER' => node[:openerp][:dev][:unix_user], 'HOME' => "/home/#{node[:openerp][:dev][:unix_user]}", 'LC_ALL'=>nil
  user node[:openerp][:dev][:unix_user]
end


