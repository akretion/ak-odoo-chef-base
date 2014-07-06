# <a name="title"></a> Akretion OpenERP Base [![Build Status](https://secure.travis-ci.org/akretion/ak-openerp-base.png?branch=master)](http://travis-ci.org/akretion/ak-openerp-base)

## <a name="description"></a> Description

Provisions server environment for OpenERP

## Recipes

#### default

Main recipe


## Usages

First, for all methods you need to clone this repo:

    git clone https://github.com/akretion/ak-odoo-chef-base.git
    cd ak-odoo-chef-base

#### 1) with Vagrant and lxc (on Linux)

* Make sure you have Vagrant installed:
VirtualBox - native packages exist for most platforms and can be downloaded from the VirtualBox downloads [page](https://www.virtualbox.org/wiki/Downloads).
* sudo apt-get install lxc
* sudo apt-get install redir
* install the vagrant-lxc plugin:

```
vagrant plugin install vagrant-lxc --plugin-version 1.0.0.alpha.2
```

you can read more here https://github.com/fgrehm/vagrant-lxc

Finally, in the repo folder, update the node attributes in the Vagrantfile or the buildout.cfg eventually

    vagrant up --provider=lxc

done!

#### 2) on Vagrant with the Virtualbox provider (Windows and old Linux distro)

TODO it's simple but I should ensure it works and document

#### 3) or on bare Ubuntu Linux

TODO the following isn't true since I dropped Berkshelf dependency. See if it's better to reintroduce Berkshelf
or change the process instead.

    rvmsudo gem install berkshelf --no-ri --no-rdoc
    rvmsudo berks install --path /var/chef/cookbooks

update the node attributes in dna.json, specially the simple_unix_user param

    rvmsudo chef-solo -j dna.json

done!
