name              "Akretion OpenERP Base"
maintainer        "Akretion"
maintainer_email  "contact@akretion.com"
license           "Apache 2.0"
description       "Provisions server environment for OpenERP"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "1.0.0"
recipe            "ak-openerp-base::default", "Default"
depends           "python"
depends           "apt"
depends           "ak-tools"

%w{ ubuntu }.each do |os|
  supports os
end
