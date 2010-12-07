require File.join(File.dirname(__FILE__), 'test_helper')
Test::Unit.run = false

require File.join(File.dirname(__FILE__), 'test_jail')
require File.join(File.dirname(__FILE__), 'test_safemode_parser')
require File.join(File.dirname(__FILE__), 'test_safemode_eval')
require File.join(File.dirname(__FILE__), 'test_erb_eval')

# ['ParseTree', 'RubyParser'].each do |parser|
['RubyParser'].each do |parser|
  Safemode::Parser.parser = parser
  puts "Running suite with Safemode::Parser using #{parser}"
  Test::Unit::AutoRunner.run
end
