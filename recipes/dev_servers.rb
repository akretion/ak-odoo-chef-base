(node[:openerp][:dev_servers] || []).each do |name, remote|
  target_dir = remote.split("/").last
  execute "rsync-#{name}" do
    command "rsync -az #{remote} . ; mv  #{target_dir} #{name}"
    creates "/home/#{node[:openerp][:dev][:unix_user]}/#{name}"
    cwd "/home/#{node[:openerp][:dev][:unix_user]}"
    user node[:openerp][:dev][:unix_user]
  end

  host = remote.split("@")[1].split(":")[0]
  ip = `nslookup #{host}`.split('Address: ').last.gsub(/\n/, '')  

  execute "parent_host-#{name}" do
    command "echo '#{ip}  #{name}_parent_host' >> /etc/hosts"
    user "root"
    not_if "grep '#{name}_parent_host' /etc/hosts", :user => "root", :group => "root"
  end

  execute "stacking_host-#{name}" do
    command "echo '#{ip}  #{name}_stacking_host' >> /etc/hosts"
    user "root"
    not_if "grep '#{name}_stacking_host' /etc/hosts", :user => "root", :group => "root"
  end

end
