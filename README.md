# <a name="title"></a> Akretion OpenERP Base [![Build Status](https://secure.travis-ci.org/akretion/ak-openerp-base.png?branch=master)](http://travis-ci.org/akretion/ak-openerp-base)

## <a name="description"></a> Description

Provisions server environment for OpenERP

## Recipes

#### default

Main recipe


## Usages

make sure you have ruby 1.9.3+ installed, ideally with rvm (else use sudo instead of rvmsudo in the following).

#### 1) with Vagrant and lxc

* sudo apt-get install lxc
* sudo apt-get install redir
* install Vagrant 1.5+ from http://www.vagrantup.com/downloads.html
* vagrant plugin install vagrant-lxc --plugin-version 1.0.0.alpha.1  #read more here https://github.com/fgrehm/vagrant-lxc

```
git clone https://github.com/akretion/ak-openerp-base.git
cd ak-openerp-base
berks vendor cookbooks
```

update the node attributes in the Vagrantfile file

```
vagrant up
```

done!

#### 2) or on bare Ubuntu Linux

    git clone https://github.com/akretion/ak-openerp-base.git
    cd ak-openerp-base
    rvmsudo gem install berkshelf --no-ri --no-rdoc
    rvmsudo berks install --path /var/chef/cookbooks

update the node attributes in node.json, specially the simple_unix_user param

    rvmsudo chef-solo -j node.json

done!
