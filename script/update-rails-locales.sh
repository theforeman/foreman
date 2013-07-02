#!/bin/bash
pushd config/locales
I18N_BRANCH="rails-3-x"
TMP=$(mktemp)
for FILE in *yml; do
  echo -n "Updating $FILE ... "
  wget "https://raw.github.com/svenfuchs/rails-i18n/$I18N_BRANCH/rails/locale/$FILE" -qO $TMP
  if [ -s $TMP ]; then
    mv $TMP "$FILE"
    echo ok
  else
    echo skipped
  fi
done
rm -f $TMP
popd
