# Simple recipe to install distro Postgresql, possibly with a ppa backport

unless ENV['LANG'].end_with?("UTF-8") || node[:simple_unix_user]
  lang = ENV['LANG'] && ENV['LANG'].split(".")[0] || "en_US"
  lang = "en_US" if lang.empty?
  lang_enc = "#{lang}.UTF-8"
  ENV['LANGUAGE'] = ENV['LANG'] = ENV['LC_ALL'] = lang_enc
  `rm /etc/default/locale; echo LANG="#{lang_enc}" >> /etc/default/locale`
  `locale-gen #{lang_enc}`
  `dpkg-reconfigure locales`
end

if node[:platform_version].to_f >= 14.04 && node[:postgresql][:version]
  node.set[:postgresql][:version] = "9.3" # we will always want 9.3 if distro package available, right?
  package "postgresql-#{node[:postgresql][:version]}"
  package "postgresql-server-dev-#{node[:postgresql][:version]}"
  
elsif node[:postgresql][:version] == "9.2" && node[:platform_version].to_f > 11.10

  apt_repository "postgresql-9.2" do
    uri "http://ppa.launchpad.net/pitti/postgresql/ubuntu"
    distribution node[:lsb][:codename]
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

  package "postgresql-9.2"
  package "postgresql-server-dev-9.2"

else
  package "postgresql"
  package "postgresql-server-dev-all"
end

service "postgresql" do
  action [:start]
end

postgresql_user node[:erp][:dev][:unix_user] do
  privileges :createdb => true, :inherit => true, :login => true
end
