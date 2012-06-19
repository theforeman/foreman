#!/bin/bash -x

APP_ROOT=`pwd`

# setup basic settings file
sed -e 's/:login: false/:login: true/' $APP_ROOT/config/settings.yaml.example > $APP_ROOT/config/settings.yaml
cp $APP_ROOT/config/database.yml.example $APP_ROOT/config/database.yml

# install runtime C libs that are required:
sudo apt-get install -y libvirt-dev
cat > $APP_ROOT/Gemfile.local.rb << EOF
gem 'facter'
gem 'puppet'
EOF
