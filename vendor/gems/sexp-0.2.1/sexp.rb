# This library used to supply 'sexp', but ParseTree also
# supplies a file named sexp.rb and comes earlier in the
# load order. I've switched this lib to the more verbose
# 'sexpressions', but this file is for compatibility.
require 'sexpressions'