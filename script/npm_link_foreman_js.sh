#!/bin/bash

# This script replace the npm installation of `foreman-js`
# with your local version. Usefull when developing `foreman-js`
# Read more about foreman-js: https://github.com/theforeman/foreman-js
#
# This script designed to run using `npm run foreman-js:link` in foreman root

set -e

if [[ -z "${FOREMAN_JS_LOCATION}" ]]; then # FOREMAN_JS_LOCATION is empty
  FOREMAN_JS_LOCATION="../foreman-js"
  echo "FOREMAN_JS_LOCATION is not defined, using \"${FOREMAN_JS_LOCATION}\" instead"
elif [ ! -d "${FOREMAN_JS_LOCATION}" ]; then
  echo "Can't find folder ${FOREMAN_JS_LOCATION}"
  exit 1
fi

FOREMAN_JS_LOCATION="../${FOREMAN_JS_LOCATION}"
FOREMAN_JS_PACKAGES_LOCATION="${FOREMAN_JS_LOCATION}/packages"
FOREMAN_JS_INSTALL_LOCATION="./node_modules/@theforeman"

set -x

rm -rf $FOREMAN_JS_INSTALL_LOCATION
ln -s $FOREMAN_JS_PACKAGES_LOCATION $FOREMAN_JS_INSTALL_LOCATION
