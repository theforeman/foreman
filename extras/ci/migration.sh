#!/bin/bash

export CHECKOUT_DIR=`pwd`

if [ ! -e $CHECKOUT_DIR/.git ]; then
    echo "This script should run in the root of a Foreman git checkout"
    exit 1
fi

function usage {
    echo "USAGE: extras/ci/migration.sh (tag|SHA) point <end_point> "
    # This function should never be called when execution is meant to succeed.
    exit 1
}

if [ $# == 2 ]; then
    echo "Performing a single-step migration."
elif [ $# == 3 ]; then
    echo "Performing a point-to-point migration."
else
    usage
fi

case $1 in
SHA)
        echo "Checking out SHA $2"
        git checkout $2
        ;;
tag)
        echo "Checking out tag $2"
        git checkout $2
        ;;
*)
        usage
esac

if [ -e Gemfile.lock ]; then
    rm Gemfile.lock
fi

echo "Bundlizing..."
bundle install

echo "Dropping the database."
rake db:drop:all

echo "Creating the new database."
rake db:create

echo "Migrating..."
rake db:migrate

if [ $# == 3 ]; then
    echo "Updating to $3"
    git checkout $3

    echo "Updating bundled gems"
    bundle update

    echo "Migrating to the new revision"
    rake db:migrate
fi

echo "You've made it this far. Looks like things are operational..."
