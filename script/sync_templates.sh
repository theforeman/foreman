#!/bin/bash
#
# Copies unattended templates from community-templates repository to
# app/views/unattended/ where they can be seeded on new installations.
#
# Not intended for use on existing installations, only for development.
# Production installations should use the foreman_templates plugin to
# update the contents of the database.

REPO=$(mktemp -d)
trap "rm -rf $REPO" EXIT

git clone -q -b $(git symbolic-ref -q HEAD --short) \
  https://github.com/theforeman/community-templates $REPO/ct

# move into destination dir if run from Foreman root
[ -d app/views/unattended ] && cd app/views/unattended

rsync -r \
  --exclude .gitignore \
  --exclude README.md \
  --exclude '.*' \
  --exclude test \
  --exclude Rakefile \
  --exclude Gemfile \
  --exclude LICENSE \
  --exclude 'job_templates/' \
  $REPO/ct/ ./

cd -

git status -- app/views/unattended

if [ $(git status --porcelain -u -- app/views/unattended | grep -c '^\?') -gt 0 ]; then
  echo
  echo "Warning: new files copied, update template snapshot tests using 'RAILS_ENV=test rake snapshots:generate' "
fi
