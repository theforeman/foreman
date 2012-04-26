#!/bin/bash -x

APP_ROOT=`pwd`

# setup basic settings file
sed -e 's/:login: false/:login: true/' $APP_ROOT/config/settings.yaml.example > $APP_ROOT/config/settings.yaml

# install runtime C libs that are required:
sudo apt-get install -y libvirt-dev
gem install puppet # travis use rvm, but we dont want it in our gemfile
