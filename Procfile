# Run Rails & Webpack concurrently
# If you wish to use a different server then the default, use e.g.
# `export RAILS_STARTUP='puma -w 3 -p 3000 --preload'`
# OR
# RAILS_STARTUP='puma -w 3 -p 3000 --preload' foreman start
rails: [ -n "$RAILS_STARTUP" ] && env PRY_WARNING=1 $RAILS_STARTUP || [ -n "$BIND" ] && bin/rails server -b $BIND || env PRY_WARNING=1 bin/rails server

# you can use environment variables as options supported by webpack-dev-server
# in the form WEBPACKER_DEV_SERVER_<OPTION>, e.g.
# WEBPACKER_DEV_SERVER_HTTPS=true \
# WEBPACKER_DEV_SERVER_KEY=/path/to/key \
# WEBPACKER_DEV_SERVER_CERT=/path/to/cert.pem \
# WEBPACKER_DEV_SERVER_CACERT=/path/to/cacert.pem \
# foreman start
webpack: ./bin/webpack-dev-server
