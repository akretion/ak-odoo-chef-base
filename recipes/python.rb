include_recipe "python::pip"

(node[:erp][:pip_packages] + node[:erp][:pip_packages_extra] + node[:erp][:pip_packages_env]).each do |pack|
  if pack.index('=') # TODO see if we can support more constraints if python_pip supports it
    items = pack.gsub('==', '=').split('=')
    python_pip items[0] do
      version items[1]
    end
  else
    python_pip(pack)
  end
end
