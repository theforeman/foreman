#!/bin/bash -x

APP_ROOT=`pwd`

# setup basic settings file
sed -e 's/:login: false/:login: true/' $APP_ROOT/config/settings.yaml.example > $APP_ROOT/config/settings.yaml

# install runtime C libs that are required:
sudo apt-get install -y libvirt-dev
echo "gem 'puppet' > Gemfile.local.rb"
