%w{
  simple_monad
  functor
  simple_parser
  operator
  keyword
  expression
  s_expression
  full_parser
  sql
}.each do |name|
  require "#{name}_test"
end