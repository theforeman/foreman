#!/bin/bash
set -e

[ -e /opt/rh/rh-ruby25/enable ] && . /opt/rh/rh-ruby25/enable
[ -e /opt/rh/rh-nodejs8/enable ] && . /opt/rh/rh-nodejs8/enable

export PATH=~/bin:${GEM_HOME}/bin:${PATH}

# Remove a potentially pre-existing server.pid for Rails.
rm -f ~/pids/server.pid

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
