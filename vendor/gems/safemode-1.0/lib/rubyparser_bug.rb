require 'rubygems'
require 'ruby2ruby'

sexp = ParseTree.translate('a')
puts Ruby2Ruby.new.process(sexp)

# should work, but yields:
# UnknownNodeError: Bug! Unknown node-type :vcall to Ruby2Ruby