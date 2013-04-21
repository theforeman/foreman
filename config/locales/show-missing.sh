#!/bin/bash
#
# This script helps you to show missing translations.
#
# To run this you need rspec and i18n-spec gems installed
#
REPODIR=$(pwd)
UPSTEAM_CLONE=$(mktemp -d -q)
trap "rm -rf $UPSTEAM_CLONE" EXIT
echo "Cloning rails-i18n (will be deleted afterwards)"
git clone git://github.com/svenfuchs/rails-i18n.git "$UPSTEAM_CLONE"
for FILE in *yml; do
  echo -n "Comparing $FILE ... "
  if [ -f "$UPSTEAM_CLONE/rails/locale/$FILE" ]; then
    pushd "$UPSTEAM_CLONE" >/dev/null
    upstream=$(rake i18n-spec:completeness rails/locale/en.yml "rails/locale/$FILE" | grep MISSING | wc -l)
    here=$(rake i18n-spec:completeness rails/locale/en.yml "$REPODIR/$FILE" | grep MISSING | wc -l)
    popd >/dev/null
    echo "missing strings: here:$here upstream:$upstream"
  else
    echo missing upstream
  fi
done
