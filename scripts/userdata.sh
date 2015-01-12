#!/bin/bash

# install dependencies
/usr/bin/yum install git -y
/usr/bin/yum install jq -y
/usr/bin/gem2.0 install puppet -v '~> 3.7' --no-ri --no-rdoc

# classfiy node
mkdir -p /etc/facter/facts.d/
echo 'role=public' > /etc/facter/facts.d/fact.txt

# install git repo
/usr/bin/git clone https://github.com/relud/puppet-demo /etc/puppet

# install secrets
/usr/bin/aws s3 cp s3://BUCKET_NAME/secret.yaml /etc/puppet/yaml/secret.yaml

# install forge modules

## list the modules to install via hiera
json_modules="$(/usr/local/bin/hiera -c /etc/puppet/hiera.yaml -a modules '::role=public')"
## convert modules from list of json strings, to newline separated strings
modules="$(echo "$json_modules" | /usr/bin/jq -r '.[]')"
## convert module strings to puppet module install commands
commands="$(echo "$modules" | /bin/sed 's,^,/usr/local/bin/puppet module install --force ,')"
## execute commands
eval "$commands"

# run puppet
/usr/local/bin/puppet apply -e "include hiera_array('classes')"
