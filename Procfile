# Run Rails & Webpack concurrently
# If you wish to use a different server then the default, use e.g. `export RAILS_STARTUP='puma -w 3 -p 3000 --preload'`
rails: [ -n "$RAILS_STARTUP" ] && $RAILS_STARTUP || bin/rails server -b 0.0.0.0
webpack: ./node_modules/.bin/webpack-dev-server --config config/webpack.config.js
