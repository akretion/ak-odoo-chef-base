include_recipe "ak-odoo-chef-base::git" # monkey patch / extension of the default git provider



if node[:simple_unix_user] && ! ::File.exist?("/home/#{node[:simple_unix_user]}")
  raise "Error! your node is configured with node[:simple_unix_user]='#{node[:simple_unix_user]}'
  but this user home directory doesn't exist. Did you forget to update your simple_unix_user in
  your specific configuration? If you really meant #{node[:simple_unix_user]},
  create this user manually before running Chef."
end

include_recipe "ak-tools::server"
include_recipe "ak-odoo-chef-base::ak-tools"
group node[:erp][:group_unix]

include_recipe "ak-odoo-chef-base::python"
include_recipe "ak-odoo-chef-base::wkhtmltopdf"

include_recipe "ak-bzr::default"

if ::File.exist?("/home/#{node[:erp][:dev][:unix_user]}")
  bzr_user_conf do
    owner node[:erp][:dev][:unix_user] 
    group node[:erp][:group_unix]
  end

  unless node[:simple_unix_user]
    include_recipe "ak-odoo-chef-base::ssh_key"
    node.default[:ak_tools][:product_name] = "Akretion dev server for #{node[:simple_unix_user]}"
  end
end

if node[:postgresql][:install] == "distro"
  include_recipe "ak-odoo-chef-base::postgresql"
end

#chef_gem "ooor"

include_recipe "ak-odoo-chef-base::demo_servers"
include_recipe "ak-odoo-chef-base::dev_servers"
