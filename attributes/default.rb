include_attribute "ak-tools"

default[:ak_tools][:product_name] = "OpenERP Akretion demo/dev server!
                                     \n    Warning! Unsecure server! Not suited for production!
                                     \nFor a professional experience, get your OpenERP deployed by www.akretion.com"


# ************************************** PACKAGES

default[:ak_tools][:apt_packages] += %w[
  python
  python-dev
  bzr
  ghostscript
  poppler-utils
  libxml2-dev
  libxslt1-dev
  libldap2-dev
  libsasl2-dev
  libssl-dev
  libjpeg-dev
  libxext6
  fontconfig
]

                                                      # quite stable python modules with C extensions
                                                      # you can override and use buildout packages instead
                                                      # but using distro packages saves us from compilation
default[:ak_tools][:apt_python_packages] = %w[
  python-pypdf
  python-reportlab
  python-yaml
  python-ldap
  python-pil
]

                                                      # you can override and use a buildout packages instead
                                                      # use the buidlout configuration if you want a pinned version
default[:erp][:pip_packages] = %w[                    
  werkzeug
  unittest2
  mock
  docutils
  gdata
  Jinja2
  requests
]

default[:erp][:pip_packages_extra] = []               # easy to customize with Chef Solo
default[:erp][:pip_packages_env] = []                 # environment wise Python packages


# ************************************* USERS

default[:simple_unix_user] = false                    # you may set it to your current unix user if not using virtualization
default[:erp][:group_unix]                            = simple_unix_user || "erp_group"
default[:erp][:dev][:unix_user]                       = simple_unix_user || (node[:vagrant] && "vagrant" || "erp_dev")
default[:erp][:dev][:authorized_ssh_key]              = ""


# ************************************* POSTGRES

default[:postgresql][:install] = "distro"             # set to false if you don't want Postgres installation


case node['platform']
when "ubuntu"
  case
  when node['platform_version'].to_f <= 11.04
    default['postgresql']['version'] = "8.4"
  when node['platform_version'].to_f <= 11.10
    default['postgresql']['version'] = "9.1"
  when node[:platform_version].to_f < 14.04
    default['postgresql']['version'] = "9.2" # via ppa backport, override if you don't like
  else
    default['postgresql']['version'] = "9.3"
  end
when "debian"
  case
  when node['platform_version'].to_f < 7.0 # All 6.X
    default['postgresql']['version'] = "8.4"
  else
    default['postgresql']['version'] = "9.1"
  end
end
