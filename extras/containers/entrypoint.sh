#!/bin/bash
set -e

export PATH=~/bin:${GEM_HOME}/bin:${PATH}

# Remove a potentially pre-existing server.pid for Rails.
rm -f ~/pids/server.pid

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
