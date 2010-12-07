%w{
parsers operators keywords expressions
}.each {|lib| require "rparsec/#{lib}"}