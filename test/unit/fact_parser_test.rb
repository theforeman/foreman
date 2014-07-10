require "test_helper"

class FactParserTest < ActiveSupport::TestCase
  test "default parsers" do
    assert_includes FactParser.parsers.keys, 'puppet'
    assert_equal PuppetFactParser, FactParser.parser_for(:puppet)
    assert_equal PuppetFactParser, FactParser.parser_for('puppet')
    assert_equal PuppetFactParser, FactParser.parser_for(:whatever)
    assert_equal PuppetFactParser, FactParser.parser_for('whatever')
  end

  test ".register_custom_parser" do
    chef_parser = Struct.new(:my_method)
    FactParser.register_fact_importer :chef, chef_parser

    assert_equal chef_parser, FactParser.parser_for(:chef)
  end
end
