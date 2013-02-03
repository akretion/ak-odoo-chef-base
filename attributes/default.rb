include_attribute "ak-tools"

default[:ak_tools][:product_name] = "OpenERP Akretion demo/dev server!
                                     \n Warning totally unsecure server! Not suited for production!
                                     \nGet your OpenERP deployed by www.akretion.com for a professional experience"

#  python-software-properties
default[:ak_tools][:apt_packages] += %w[
  python
  python-psycopg2
  python-reportlab
  python-tz
  python-mako
  python-pychart
  python-pydot
  python-lxml
  python-vobject
  python-pip
  python-pybabel
  python-simplejson
  python-dateutil
  python-openid
  python-imaging
  python-dev
  ghostscript
  poppler-utils
]

default[:openerp][:pip_packages] = %w[PyYaml werkzeug unittest2 mock docutils gdata Jinja2] #TODO pin versions?
default[:openerp][:pip_packages_extra] = [] #easy to customize with Chef Solo

default[:simple_unix_user] = false
default[:openerp][:group_unix]                            = simple_unix_user || "erp_group"
default[:openerp][:dev][:unix_user]                       = simple_unix_user || (node[:vagrant] && "vagrant" || "erp_dev")
default[:openerp][:dev][:authorized_ssh_key]              = ""

default[:postgresql][:install] = "distro"
default[:postgresql][:version] = "9.2"
default[:postgresql][:pg_ident] = {"openerp" => {openerp[:dev][:unix_user] => openerp[:dev][:unix_user]}}
