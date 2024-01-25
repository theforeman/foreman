# Run Rails & Webpack concurrently
# If you wish to use a different server then the default, use e.g. `export RAILS_STARTUP='puma -w 3 -p 3000 --preload'`
rails: [ -n "$RAILS_STARTUP" ] && env PRY_WARNING=1 $RAILS_STARTUP || [ -n "$BIND" ] && bin/rails server -b $BIND || env PRY_WARNING=1 bin/rails server

# you can use WEBPACK_OPTS to customize webpack server, e.g. 'WEBPACK_OPTS=--progress' foreman start '
# filter out webpack options that are commonly used but not supported by webpack 5 and not needed in the new configutation as webpack is not run as a server anymore
webpack: FILTERED_WEBPACK_OPTS=$(echo $WEBPACK_OPTS | sed -e 's/--key [^ ]*//g' -e 's/--public [^ ]*//g' -e 's/--https [^ ]*//g' -e 's/--cert [^ ]*//g' -e 's/--cacert [^ ]*//g') && [ -n "$NODE_ENV" ] && npx webpack --config config/webpack.config.js --watch $FILTERED_WEBPACK_OPTS || env NODE_ENV=development npx webpack --config config/webpack.config.js --watch $FILTERED_WEBPACK_OPTS