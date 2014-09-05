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

  test "#parse_interfaces? should answer based on current setttings" do
    parser = get_parser
    parser.stub(:support_interfaces_parsing?, true) do
      Setting.expects(:[]).with('ignore_puppet_facts_for_provisioning').returns(false)
      assert parser.parse_interfaces?

      Setting.expects(:[]).with('ignore_puppet_facts_for_provisioning').returns(true)
      refute parser.parse_interfaces?
    end
  end

  test "#ignored_interfaces is always regular expression" do
    assert_kind_of Regexp, get_parser.send(:ignored_interfaces)
  end

  test "#remove_ignored uses ignored_interfaces regular to remove ignored interfaces" do
    parser = get_parser
    parser.stub(:ignored_interfaces, /^b|^d/) do
      assert_equal ['a', 'c'], parser.send(:remove_ignored, ['a', 'b', 'c', 'd'])
    end
  end

  test "#normalize_interfaces converts custom-case interface names to be downcase" do
    parser = get_parser
    assert_equal ['eth0', 'eth0.0', 'em1'], parser.send(:normalize_interfaces, ['ETH0', 'Eth0.0', 'eM1'])
  end

  test "#interfaces gets facts hash for desired interfaces, keeping same values it gets from parser" do
    parser = get_parser
    parser.stub(:get_interfaces, ['eth1', 'lo', 'eth0', 'eth0.0', 'local', 'usb0', 'vnet0', 'br0', 'virbr0']) do
      parser.expects(:get_facts_for_interface).with('eth1').returns({'link' => 'false', 'macaddress' => '00:00:00:00:00:AB'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('eth0').returns({'link' => 'true', 'macaddress' => '00:00:00:00:00:cd', 'custom' => 'value'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('eth0.0').returns({'link' => 'true', 'macaddress' => '00:00:00:00:00:cd', 'ipaddress' => '192.168.0.1'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('br0').returns({'link' => 'true', 'macaddress' => '00:00:00:00:00:ef'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('virbr0').returns({'link' => 'true', 'macaddress' => '00:00:00:00:ab:ef'}.with_indifferent_access)
      result = parser.interfaces
      refute_includes result.keys, 'lo'
      refute_includes result.keys, 'usb0'
      refute_includes result.keys, 'vnet0'
      assert_includes result.keys, 'br0'
      assert_includes result.keys, 'virbr0'
      assert_includes result.keys, 'eth1'
      assert_includes result.keys, 'eth0'
      assert_includes result.keys, 'eth0.0'
      assert_equal 'true', result['eth0']['link']
      assert_equal 'false', result['eth1']['link']
      assert_equal 'value', result[:eth0]['custom']
      assert_equal '192.168.0.1', result['eth0.0'][:ipaddress]
    end
  end

  test "#set_additional_attributes detects physical interface" do
    parser = get_parser

    result = parser.send(:set_additional_attributes, {}, 'eth0')
    refute result[:virtual]

    result = parser.send(:set_additional_attributes, {}, 'em1')
    refute result[:virtual]
  end

  test "#set_additional_attributes detects virtual interface" do
    parser = get_parser(:vlans => '1,2')

    result = parser.send(:set_additional_attributes, {}, 'eth0_0')
    assert result[:virtual]
    assert_equal 'eth0', result[:physical_device]
    assert_equal '', result[:tag]
    refute result[:bridge]

    result = parser.send(:set_additional_attributes, {}, 'eth0_1')
    assert result[:virtual]
    assert_equal 'eth0', result[:physical_device]
    assert_equal '1', result[:tag]
    refute result[:bridge]

    result = parser.send(:set_additional_attributes, {}, 'eth0_2')
    assert result[:virtual]
    assert_equal 'eth0', result[:physical_device]
    assert_equal '2', result[:tag]
    refute result[:bridge]

    result = parser.send(:set_additional_attributes, {}, 'eth0_4')
    assert result[:virtual]
    assert_equal 'eth0', result[:physical_device]
    assert_equal '', result[:tag]
    refute result[:bridge]
  end

  test "#set_additional_attributes detects bridged" do
    parser = get_parser

    result = parser.send(:set_additional_attributes, {}, 'br0')
    assert result[:virtual]
    assert_empty result[:physical_device]
    assert_empty result[:tag]
    assert result[:bridge]

    result = parser.send(:set_additional_attributes, {}, 'virbr0')
    assert result[:virtual]
    assert_empty result[:physical_device]
    assert_empty result[:tag]
    assert result[:bridge]
  end

  def get_parser(facts = {})
    FactParser.new(facts)
  end
end
