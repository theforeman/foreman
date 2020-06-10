#!/bin/bash
set -ev
if [[ $( git diff --name-only origin/develop..HEAD config/webpack.config.js webpack/ .travis.yml package.json | wc -l ) -ne 0 ]]; then
  npm run test;
  npm run publish-coverage;
  npm run lint;
  bash ./script/travis_run_katello_js_tests.sh
fi
