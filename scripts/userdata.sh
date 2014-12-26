#!/bin/bash
n=1

# install dependencies
/usr/bin/yum install git -y
/usr/bin/yum install jq -y
/usr/bin/gem2.0 install puppet -v '~> 3.7' --no-ri --no-rdoc
/usr/bin/gem2.0 install hiera --no-ri --no-rdoc

# classify this node as a webapp
/bin/mkdir -p /etc/facter/facts.d
/bin/echo 'type=webapp' > /etc/facter/facts.d/classify.txt

# install git repo
/usr/bin/git clone https://github.com/relud/puppet-demo /etc/puppet

# install secrets
/bin/mkdir -p /etc/puppet/yaml/secrets
/bin/touch /etc/puppet/yaml/secrets/common.yaml /etc/puppet/yaml/secrets/webapp.yaml
/bin/chmod 0600 -R /etc/puppet/yaml/secrets
/usr/bin/aws s3 cp s3://relud-demo-$n/common.yaml /etc/puppet/yaml/secrets/common.yaml
/usr/bin/aws s3 cp s3://relud-demo-$n/webapp.yaml /etc/puppet/yaml/secrets/webapp.yaml

# install dependency modules
/usr/local/bin/facter -p -j |
    /bin/sed 's/^  "/  "::/' |
    /usr/local/bin/hiera -c /etc/puppet/hiera.yaml --yaml /dev/stdin -a modules |
    /usr/bin/jq '.[]' |
    /usr/bin/xargs -n1 echo /usr/local/bin/puppet module install --force |
    /bin/bash

# run puppet
/usr/local/bin/puppet apply /etc/puppet/manifests/site.pp
