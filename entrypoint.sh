#!/bin/bash
set -e

[ -e /opt/rh/${RUBY_SCL}/enable ] && . /opt/rh/${RUBY_SCL}/enable
[ -e /opt/rh/${NODEJS_SCL}/enable ] && . /opt/rh/${NODEJS_SCL}/enable

export PATH=~/bin:${GEM_HOME}/bin:${PATH}

# Remove a potentially pre-existing server.pid for Rails.
rm -f ~/pids/server.pid

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
