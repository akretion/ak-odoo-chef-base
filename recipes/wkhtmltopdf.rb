if node[:platform_version].to_f >= 14.04
  release = "trusty"
else
  release = "precise"
end

if node['kernel']['machine'] == 'x86_64'
  arch = "amd64"
else
  arch = "i386"
end

execute 'install wkhtmltopdf' do
  command "wget http://downloads.sourceforge.net/project/wkhtmltopdf/0.12.1-dev/wkhtmltox-0.12.1-9615f00_linux-#{release}-#{arch}.deb; dpkg -i wkhtmltox-0.12.1-9615f00_linux-trusty-amd64.deb"
  not_if {`which wkhtmltopdf` != ''}
end
