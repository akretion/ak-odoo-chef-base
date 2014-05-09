if node[:simple_unix_user] && ! ::File.exist?("/home/#{node[:simple_unix_user]}")
  raise "Error! your node is configured with node[:simple_unix_user]='#{node[:simple_unix_user]}'
  but this user home directory doesn't exist. Did you forget to update your simple_unix_user in
  your specific configuration? If you really meant #{node[:simple_unix_user]},
  create this user manually before running Chef."
end

include_recipe "ak-tools::server"
group node[:openerp][:group_unix]

include_recipe "ak-openerp-base::python"
include_recipe "ak-openerp-base::bzr"
include_recipe "ak-openerp-base::ak-tools"

if node[:postgresql][:install] == "distro"
  include_recipe "ak-openerp-base::postgresql"
end

unless node[:simple_unix_user]
  include_recipe "ak-openerp-base::ssh_key"
  node.default[:ak_tools][:product_name] = "Akretion dev server for #{node[:simple_unix_user]}"
end
#chef_gem "ooor"

include_recipe "ak-openerp-base::demo_servers"
include_recipe "ak-openerp-base::dev_servers"
