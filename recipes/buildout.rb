include_recipe "ak-odoo-chef-base::default"

(node[:erp][:buildouts] || []).each do |name, repo|
  buildout name do
    repository repo
    user node[:erp][:dev][:unix_user]
    group node[:erp][:group_unix]
  end
end
