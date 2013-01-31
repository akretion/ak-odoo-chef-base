#Configure bashrc
cookbook_file "/etc/bash_ak_aliases" do
  source "bash_ak_aliases"
  owner "root"
  group "root"
  mode "0644"
  #  notifies :run, "execute[source_profile]" #TODO doesn't work see http://www.ruby-forum.com/topic/90829
end

script "ak tools" do
  interpreter "ruby"
  user "root"
  group "root"
  code <<-EOH
  File.open('/etc/bash.bashrc', 'a') do |f|
    f.puts("# Add ak bash aliases.
    if [ -f /etc/bash_ak_aliases ]; then
      source /etc/bash_ak_aliases
      fi")
    end
  EOH
  not_if "grep '# Add ak bash aliases.' /etc/bash.bashrc", :user => "root", :group => "root"
end

execute "source_profile" do
  command "source /etc/bash.bashrc" #TODO doesn't work in current shell
  action :nothing
  user "root"
end

['bzr_pull_all', 'bzr_push_all', 'bzr_update_all', 'ak-db'].each do |file|
  cookbook_file "/usr/local/bin/#{file}" do
    source "aktools/bin-server/#{file}"
    owner "root"
    group "root"
    mode "0755"
  end
end

if File.exists?("/usr/local/rvm") #FIXME this is a brittle test for RVM installation
  include_recipe "ak-openerp::rvm"
  rvm_global_gem "thor"

  rvm_wrapper "ak" do
    ruby_string   node[:rvm][:default_ruby]
    binary        "chef-client"
  end
else
  gem_package "thor"
end

['ak-db-base.rb'].each do |file|
  cookbook_file "/usr/local/lib/ak-lib/#{file}" do
    source "aktools/lib/#{file}"
    owner "root"
    group "root"
    mode "0755"
  end
end