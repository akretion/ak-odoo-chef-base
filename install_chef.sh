#!/bin/bash

# Kill possibly running Odoo server and unfinished Chef run on Vagrant
sudo killall python
#sudo killall chef-client

command="wget -O - https://www.opscode.com/chef/install.sh | sudo bash"

repo_list=(
    http://github.com/akretion/ak-tools.git
    http://github.com/opscode-cookbooks/apt.git
    https://github.com/poise/python.git
    http://github.com/opscode-cookbooks/build-essential.git
    http://github.com/opscode-cookbooks/yum-epel.git
    http://github.com/opscode-cookbooks/yum.git
    http://github.com/opscode-cookbooks/ssh_known_hosts.git
    http://github.com/opscode-cookbooks/partial_search.git
)

set -e

#Install last version of chef
if [ ! -d "/opt/chef" ]
then
    echo "Install last chef version."
    eval $command
else
    version=$(chef-client -v)
    min_version='Chef: 11.0.0'
    if [[ "$version" < "$min_version" ]]
    then
        echo "Actual Chef version is $version, minimal version required min version $minversion. Update it."
        eval $command
    else
        echo "The version of Chef is correct, enjoy Akretion cookbook !"
    fi
fi

if [ ! -f "/etc/chef-solo/cookbooks/cookbooks/ak-odoo-chef-base/metadata.rb" ]
then
    echo "Download cookbooks"
    sudo apt-get install git -y
    mkdir -p /etc/chef-solo/cookbooks/cookbooks
    cd /etc/chef-solo/cookbooks/cookbooks
    for repo in ${repo_list[*]}
    do
        echo "download cookbook from $repo"
        git clone $repo
    done
    ln -s /vagrant ak-odoo-chef-base
fi
