#!/bin/bash

# This script will allow you to run tfm-stories
# while foreman can still use webpack-3 for the normal build.
# 
# It is here temporarily until the migration to webpack-4 will be done. 

if [ "$NODE_ENV" = "production" ]; then
  exit 0
fi

if [ -d node_modules/@theforeman/stories/node_modules ]; then
  exit 0
fi

cd ./node_modules/@theforeman/stories
npm install