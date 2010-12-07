# $: << "#{File.dirname(__FILE__)}/../.."

def import *names
  names.each {|lib|require "rparsec/#{lib}"}
end