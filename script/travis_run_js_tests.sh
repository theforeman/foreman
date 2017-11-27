#!/bin/bash
set -ev
if [[ $( git diff --name-only HEAD~1..HEAD config/webpacker.yml config/webpack/ webpack/ app/javascript/packs/ .travis.yml package.json | wc -l ) -ne 0 ]]; then
  npm run test;
fi
