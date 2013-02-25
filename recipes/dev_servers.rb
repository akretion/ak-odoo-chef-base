(node[:openerp][:dev_servers] || []).each do |name, remote|
  execute "rsync-#{name}" do
    command "rsync -az #{remote} #{name}"
    creates "/home/#{node[:openerp][:dev][:unix_user]}/#{name}"
    cwd "/home/#{node[:openerp][:dev][:unix_user]}"
    user node[:openerp][:dev][:unix_user]
  end
end
