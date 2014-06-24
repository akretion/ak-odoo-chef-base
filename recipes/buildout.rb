include_recipe "ak-odoo-chef-base::default"

(node[:erp][:buildouts] || []).each do |name, repo|
  buildout "/home/vagrant/#{name}" do
    repository repo
    user 'vagrant'
    group 'vagrant'
  end
end
