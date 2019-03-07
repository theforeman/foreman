# Run Rails & Webpack concurrently
# If you wish to use a different server then the default, use e.g. `export RAILS_STARTUP='puma -w 3 -p 3000 --preload'`
rails: [ -n "$RAILS_STARTUP" ] && env PRY_WARNING=1 $RAILS_STARTUP || [ -n "$BIND" ] && bin/rails server -b $BIND || env PRY_WARNING=1 bin/rails server
# you can use WEBPACK_OPTS to customize webpack server, e.g. 'WEBPACK_OPTS='--https --key /path/to/key --cert /path/to/cert.pem --cacert /path/to/cacert.pem' foreman start '
webpack: [ -n "$NODE_ENV" ] && ./node_modules/.bin/webpack-dev-server --config config/webpack.config.js $WEBPACK_OPTS || env NODE_ENV=development ./node_modules/.bin/webpack-dev-server --config config/webpack.config.js $WEBPACK_OPTS
