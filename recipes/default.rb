include_recipe "ak-tools::server"
group node[:openerp][:group_unix]

include_recipe "ak-openerp-base::python"
include_recipe "ak-openerp-base::bzr"
include_recipe "ak-openerp-base::ak-tools"

if node[:postgresql][:install] == "distro"
  if node[:postgresql][:version] == "9.2" && node[:platform_version].to_f > 11.10

    apt_repository "postgresql-9.2" do
      uri "http://ppa.launchpad.net/pitti/postgresql/ubuntu"
      distribution node['lsb']['codename']
      components %w(main)
      keyserver 'keyserver.ubuntu.com'
      key '8683D8A2'
      action :add
      notifies :run, "execute[package-pg]", :immediately
    end

    execute "package-pg" do
      command "apt-get update"
      action :nothing
      notifies :install, "package[postgresql-9.2]", :immediately
    end

    package "postgresql-9.2" do
      action :install
    end

  else
    package "postgresql"
  end

  service "postgresql" do
    action [:start]
  end

  postgresql_user node[:openerp][:dev][:unix_user] do
    privileges :createdb => true, :inherit => true, :login => true
  end
end

unless node[:simple_unix_user]
  include_recipe "ak-openerp-base::ssh_key"
  include_recipe "ak-openerp-base::ak-tools"
  chef_gem "ooor" #TODO put in path till RVM is installed eventually
end
