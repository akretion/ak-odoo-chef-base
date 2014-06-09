name              "ak-odoo-chef-base"
maintainer        "Akretion"
maintainer_email  "contact@akretion.com"
license           "Apache 2.0"
description       "Provisions server environment for OpenERP"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.0.1"
recipe            "ak-odoo-chef-base::default", "Default"
depends           "python"
depends           "apt"
depends           "ak-tools"
depends           "ak-bzr"

%w{ ubuntu }.each do |os|
  supports os
end
