# Run Rails & Webpack concurrently
# If you wish to use a different server then the default, use e.g. `export RAILS_STARTUP='puma -w 3 -p 3000 --preload'`
rails: [ -n "$RAILS_STARTUP" ] && env PRY_WARNING=1 $RAILS_STARTUP || [ -n "$BIND" ] && bin/rails server -b $BIND || env PRY_WARNING=1 bin/rails server

webpack: env NODE_OPTIONS="--max-old-space-size=8096 $NODE_OPTIONS" NODE_ENV=${NODE_ENV:-development} npx webpack --config config/webpack.config.js --watch $WEBPACK_OPTS
