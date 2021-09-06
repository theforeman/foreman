require 'test_helper'

class FactParserRegistryTest < ActiveSupport::TestCase
  test "default parsers" do
    assert_equal PuppetFactParser, Foreman::Plugin.fact_parser_registry[:puppet]
    assert_equal PuppetFactParser, Foreman::Plugin.fact_parser_registry['puppet']
    assert_equal PuppetFactParser, Foreman::Plugin.fact_parser_registry[:whatever]
    assert_equal PuppetFactParser, Foreman::Plugin.fact_parser_registry['whatever']
  end

  test "register_custom_parser" do
    chef_parser = Struct.new(:my_method)
    Foreman::Plugin.fact_parser_registry.register(:chef, chef_parser)
    begin
      assert_equal chef_parser, Foreman::Plugin.fact_parser_registry[:chef]
    ensure
      Foreman::Plugin.fact_parser_registry.unregister(:chef)
    end
  end

  test "replacing parsers" do
    parser_one = Struct.new(:my_method_one)
    parser_two = Struct.new(:my_method_two)
    begin
      Foreman::Plugin.fact_parser_registry.register(:parser, parser_one)
      assert_equal parser_one, Foreman::Plugin.fact_parser_registry[:parser]
      Foreman::Plugin.fact_parser_registry.register(:parser, parser_two)
      assert_equal parser_two, Foreman::Plugin.fact_parser_registry[:parser]
    ensure
      Foreman::Plugin.fact_parser_registry.unregister(:parser)
    end
  end

  test 'replacing default parser' do
    parser_one = Struct.new(:my_method_one)
    parser_two = Struct.new(:my_method_two)

    begin
      Foreman::Plugin.fact_parser_registry.register(:parser, parser_one, true)
      assert_equal parser_one, Foreman::Plugin.fact_parser_registry[:parser]
      assert_equal parser_one, Foreman::Plugin.fact_parser_registry[:anything]
      Foreman::Plugin.fact_parser_registry.register(:parser, parser_two, true)
      assert_equal parser_two, Foreman::Plugin.fact_parser_registry[:parser]
      assert_equal parser_two, Foreman::Plugin.fact_parser_registry[:anything]
    ensure
      Foreman::Plugin.fact_parser_registry.unregister(:parser)
      Foreman::Plugin.fact_parser_registry.register(:pupper, PuppetFactParser, true)
    end
  end
end
