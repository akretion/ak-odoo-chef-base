(node[:openerp][:demo_servers] || []).each do |name, parts|

  directory "/home/#{node[:openerp][:dev][:unix_user]}/#{name}" do
    owner node[:openerp][:dev][:unix_user]
    group node[:openerp][:group_unix]
  end

  parts.each do |folder, branch|
    execute "bzr-#{folder}" do
      command "bzr branch --stacked #{branch} #{folder}"
      creates "/home/#{node[:openerp][:dev][:unix_user]}/#{name}/#{folder}"
      cwd "/home/#{node[:openerp][:dev][:unix_user]}/#{name}"
      user node[:openerp][:dev][:unix_user]
    end
  end

  addons_path = parts.keys.reject{|i| i.to_s == "server"}.map{|i| "../#{i.to_s == "web" ? "web/addons" : i}"}.join(",")
  execute "run-demo-#{name}" do
    command "./openerp-server --addons-path=#{addons_path}"
    cwd "/home/#{node[:openerp][:dev][:unix_user]}/#{name}/server"
    user node[:openerp][:dev][:unix_user]
  end

end
