include_recipe "python::pip" #TODO add missing for v7
#TODO deal with versions if item is a hash
(node[:openerp][:pip_packages] + node[:openerp][:pip_packages_extra]).each do |pack|
  python_pip(pack) { action :install }
end