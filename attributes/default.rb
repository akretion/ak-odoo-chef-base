include_attribute "ak-tools"

default[:ak_tools][:product_name] = "OpenERP Akretion demo/dev server!
                                     \n Warning totally unsecure server! Not suited for production!
                                     \nGet your OpenERP deployed by www.akretion.com for a professional experience"

#  python-software-properties
default[:ak_tools][:apt_packages] += %w[
  python
  python-dev
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

default[:erp][:pip_packages] = %w[PyYaml werkzeug unittest2 mock docutils gdata Jinja2 requests] #TODO pin versions?
default[:erp][:pip_packages_extra] = [] # easy to customize with Chef Solo
default[:erp][:pip_packages_env] = [] # environment wise python packages

default[:simple_unix_user] = false
default[:erp][:group_unix]                            = simple_unix_user || "erp_group"
default[:erp][:dev][:unix_user]                       = simple_unix_user || (node[:vagrant] && "vagrant" || "erp_dev")
default[:erp][:dev][:authorized_ssh_key]              = ""

default[:postgresql][:install] = "distro"
default[:postgresql][:version] = "9.2"
default[:postgresql][:pg_ident] = {"openerp" => {erp[:dev][:unix_user] => erp[:dev][:unix_user]}}
