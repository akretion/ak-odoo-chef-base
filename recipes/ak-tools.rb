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

['bzr_pull_all', 'bzr_push_all', 'bzr_update_all', 'ak-db', 'ak-code'].each do |file|
  cookbook_file "/usr/local/bin/#{file}" do
    source "aktools/bin-server/#{file}"
    owner "root"
    group "root"
    mode "0755"
  end
end

if defined?(RVM)
  rvm_global_gem "thor"
  rvm_global_gem "open4"

  rvm_wrapper "ak" do
    ruby_string   node[:rvm][:default_ruby]
    binary        "chef-client"
  end
else
  gem_package "thor"
  gem_package "open4"
end

['ak-db-base.rb', 'ak-code-base.rb'].each do |file|
  cookbook_file "/usr/local/lib/ak-lib/#{file}" do
    source "aktools/lib/#{file}"
    owner "root"
    group "root"
    mode "0755"
  end
end

#S3 utilities:
package "libxml2-dev"
package "libxslt1-dev"
package "s3cmd" #do
#  notifies :run, "execute[patch-S3-progressbar]", :immediately #TODO adapt ak-db command just for simple S3 retrieval
#end

#execute "patch-S3-progressbar" do #hacky workaround I found so that using it in Ruby displays the transfer progresses
#  command """sed -i 's/def update(self, current_position = -1, delta_position = -1):/def update(self, current_position = -1, delta_position = -1):\\n                sys.stdout.write(chr(10))/' /usr/share/s3cmd/S3/Progress.py"""
#  action :nothing
#end
