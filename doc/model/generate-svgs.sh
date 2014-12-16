#!/bin/sh
set -e
set -x

rm *.svg
java -jar ./plantuml.jar -- -duration -tsvg ./*.puml

cd presentation/public/images
rm *.svg
ln -s ../../../*.svg .
