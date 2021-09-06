require "test_helper"

class FactParserTest < ActiveSupport::TestCase
  attr_reader :parser, :host

  setup do
    @parser = get_parser
  end

  test "bond regexp matches only bonds" do
    assert_match FactParser::BONDS, 'bond0'
    assert_match FactParser::BONDS, 'lagg0'
    refute_match FactParser::BONDS, 'bond0.0'
    refute_match FactParser::BONDS, 'bond0:0'
    refute_match FactParser::BONDS, 'bond0.0:0'
  end

  test "bridge regexp matches bridges" do
    assert_match FactParser::BRIDGES, 'br12'
    assert_match FactParser::BRIDGES, 'br-ex'
    assert_match FactParser::BRIDGES, 'virbr1'
    refute_match FactParser::BRIDGES, 'bridge'
  end

  test "#parse_interfaces? should answer based on current setttings" do
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
    parser.stub(:ignored_interfaces, /^b|^d/) do
      assert_equal ['a', 'c'], parser.send(:remove_ignored, ['a', 'b', 'c', 'd'])
    end
  end

  test "#interfaces gets facts hash for desired interfaces, keeping same values it gets from parser" do
    parser.stub(:get_interfaces, ['eth1', 'lo', 'eth0', 'eth0.0', 'usb0', 'vnet0', 'br0', 'virbr0', 'Local_Area_Connection_2', 'macvtap0']) do
      parser.expects(:get_facts_for_interface).with('eth1').returns({'link' => 'false', 'macaddress' => '00:00:00:00:00:AB'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('eth0').returns({'link' => 'true', 'macaddress' => '00:00:00:00:00:cd', 'custom' => 'value'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('eth0.0').returns({'link' => 'true', 'macaddress' => '00:00:00:00:00:cd', 'ipaddress' => '192.168.0.1'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('br0').returns({'link' => 'true', 'macaddress' => '00:00:00:00:00:ef'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('virbr0').returns({'link' => 'true', 'macaddress' => '00:00:00:00:ab:ef'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('Local_Area_Connection_2').returns({'link' => 'true', 'macaddress' => '00:00:00:00:de:ef'}.with_indifferent_access)
      result = parser.interfaces
      refute_includes result.keys, 'lo'
      refute_includes result.keys, 'usb0'
      refute_includes result.keys, 'vnet0'
      refute_includes result.keys, 'macvtap0'
      assert_includes result.keys, 'br0'
      assert_includes result.keys, 'virbr0'
      assert_includes result.keys, 'eth1'
      assert_includes result.keys, 'eth0'
      assert_includes result.keys, 'eth0.0'
      assert_includes result.keys, 'Local_Area_Connection_2'
      assert_equal 'true', result['eth0']['link']
      assert_equal 'false', result['eth1']['link']
      assert_equal 'value', result[:eth0]['custom']
      assert_equal '192.168.0.1', result['eth0.0'][:ipaddress]
    end
  end

  context "with physical and virtual interfaces" do
    setup do
      parser.expects(:get_interfaces).returns(['eth0', 'eth0_0', 'br0', 'bond0'])
      parser.expects(:get_facts_for_interface).with('eth0').returns({'link' => 'false', 'macaddress' => '00:00:00:00:00:AB'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('eth0_0').returns({'link' => 'true', 'macaddress' => '00:00:00:00:00:cd', 'custom' => 'value'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('br0').returns({'link' => 'true', 'macaddress' => '00:00:00:00:00:cd', 'ipaddress' => '192.168.0.1'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('bond0').returns({'link' => 'true', 'macaddress' => '00:00:00:00:00:ef'}.with_indifferent_access)
    end

    test "#find_physical_interface finds the first physical interface" do
      result = parser.send(:find_physical_interface, parser.interfaces)
      refute_includes result, 'eth0_0'
      refute_includes result, 'br0'
      refute_includes result, 'bond0'
      assert_includes result, 'eth0'
    end

    test "#find_virtual_interface finds the first virtual interface" do
      result = parser.send(:find_virtual_interface, parser.interfaces)
      assert_includes result, 'eth0_0'
      refute_includes result, 'br0'
      refute_includes result, 'bond0'
      refute_includes result, 'eth0'
    end
  end

  test "#find_virtual_interface finds a bridge interface" do
    parser.stub(:get_interfaces, ['eth0', 'br0']) do
      parser.expects(:get_facts_for_interface).with('eth0').returns({'link' => 'false', 'macaddress' => '00:00:00:00:00:AB'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('br0').returns({'link' => 'true', 'macaddress' => '00:00:00:00:00:cd', 'ipaddress' => '192.168.0.1'}.with_indifferent_access)
      result = parser.send(:find_virtual_interface, parser.interfaces)
      assert_includes result, 'br0'
      refute_includes result, 'eth0'
    end
  end

  test "#find_virtual_interface finds a bond interface" do
    parser.stub(:get_interfaces, ['eth0', 'bond0']) do
      parser.expects(:get_facts_for_interface).with('eth0').returns({'link' => 'false', 'macaddress' => '00:00:00:00:00:AB'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('bond0').returns({'link' => 'true', 'macaddress' => '00:00:00:00:00:cd', 'ipaddress' => '192.168.0.1'}.with_indifferent_access)
      result = parser.send(:find_virtual_interface, parser.interfaces)
      assert_includes result, 'bond0'
      refute_includes result, 'eth0'
    end
  end

  test "#find_virtual_interface finds a vlan interface (facter < v3.0)" do
    parser.stub(:get_interfaces, ['eth0', 'eth0_0']) do
      parser.expects(:get_facts_for_interface).with('eth0').returns({'link' => 'false', 'macaddress' => '00:00:00:00:00:AB'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('eth0_0').returns({'link' => 'true', 'macaddress' => '00:00:00:00:00:cd', 'ipaddress' => '192.168.0.1'}.with_indifferent_access)
      result = parser.send(:find_virtual_interface, parser.interfaces)
      assert_includes result, 'eth0_0'
      refute_includes result, 'eth0'
    end
  end

  test "#find_virtual_interface finds a vlan interface (facter >= v3.0)" do
    parser.stub(:get_interfaces, ['eth0', 'eth0.0']) do
      parser.expects(:get_facts_for_interface).with('eth0').returns({'link' => 'false', 'macaddress' => '00:00:00:00:00:AB'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('eth0.0').returns({'link' => 'true', 'macaddress' => '00:00:00:00:00:cd', 'ipaddress' => '192.168.0.1'}.with_indifferent_access)
      result = parser.send(:find_virtual_interface, parser.interfaces)
      assert_includes result, 'eth0.0'
      refute_includes result, 'eth0'
    end
  end

  test "#find_virtual_interface finds an interface with an alphanum alias (facter < v3.0)" do
    parser.stub(:get_interfaces, ['eth0', 'eth0_bar']) do
      parser.expects(:get_facts_for_interface).with('eth0').returns({'link' => 'false', 'macaddress' => '00:00:00:00:00:AB'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('eth0_bar').returns({'link' => 'true', 'macaddress' => '00:00:00:00:00:cd', 'ipaddress' => '192.168.0.1'}.with_indifferent_access)
      result = parser.send(:find_virtual_interface, parser.interfaces)
      assert_includes result, 'eth0_bar'
      refute_includes result, 'eth0'
    end
  end

  test "#find_virtual_interface finds an interface with an alias (facter >= v3.0)" do
    parser.stub(:get_interfaces, ['eth0', 'eth0:1']) do
      parser.expects(:get_facts_for_interface).with('eth0').returns({'link' => 'false', 'macaddress' => '00:00:00:00:00:AB'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('eth0:1').returns({'link' => 'true', 'macaddress' => '00:00:00:00:00:cd', 'ipaddress' => '192.168.0.1'}.with_indifferent_access)
      result = parser.send(:find_virtual_interface, parser.interfaces)
      assert_includes result, 'eth0:1'
      refute_includes result, 'eth0'
    end
  end

  test "#find_virtual_interface does not find physical interfaces" do
    parser.stub(:get_interfaces, ['eth0', 'enp0s25', 'em1', 'eno1']) do
      parser.expects(:get_facts_for_interface).with('eth0').returns({'link' => 'false', 'macaddress' => '00:00:00:00:00:AB'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('enp0s25').returns({'link' => 'true', 'macaddress' => '00:00:00:00:00:cd', 'ipaddress' => '192.168.0.1'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('em1').returns({'link' => 'true', 'macaddress' => '00:00:00:00:00:cd', 'ipaddress' => '192.168.0.1'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('eno1').returns({'link' => 'true', 'macaddress' => '00:00:00:00:00:cd', 'ipaddress' => '192.168.0.1'}.with_indifferent_access)
      result = parser.send(:find_virtual_interface, parser.interfaces)
      assert_nil result
    end
  end

  test "#find_physical_interface does not find virtual interfaces" do
    parser.stub(:get_interfaces, ['eth0_0', 'br42', 'virbr0', 'bond7', 'eth0.100', 'eth0:1', 'eth0.100:1', 'bond7:1', 'bond7.100', 'bond7.100:1']) do
      parser.expects(:get_facts_for_interface).with('eth0_0').returns({'link' => 'false', 'macaddress' => '00:00:00:00:00:AB'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('br42').returns({'link' => 'true', 'macaddress' => '00:00:00:00:00:cd', 'ipaddress' => '192.168.0.1'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('virbr0').returns({'link' => 'true', 'macaddress' => '00:00:00:00:00:cd', 'ipaddress' => '192.168.0.1'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('bond7').returns({'link' => 'true', 'macaddress' => '00:00:00:00:00:cd', 'ipaddress' => '192.168.0.1'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('eth0.100').returns({'link' => 'false', 'macaddress' => '00:00:00:00:00:AB', 'ipaddress' => '192.168.100.2'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('eth0:1').returns({'link' => 'false', 'macaddress' => '00:00:00:00:00:AB'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('eth0.100:1').returns({'link' => 'false', 'macaddress' => '00:00:00:00:00:AB', 'ipaddress' => '192.168.100.2'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('bond7:1').returns({'link' => 'true', 'macaddress' => '00:00:00:00:00:cd', 'ipaddress' => '192.168.0.2'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('bond7.100').returns({'link' => 'true', 'macaddress' => '00:00:00:00:00:cd', 'ipaddress' => '192.168.100.1'}.with_indifferent_access)
      parser.expects(:get_facts_for_interface).with('bond7.100:1').returns({'link' => 'true', 'macaddress' => '00:00:00:00:00:cd', 'ipaddress' => '192.168.100.2'}.with_indifferent_access)
      result = parser.send(:find_physical_interface, parser.interfaces)
      assert_nil result
    end
  end

  test "#set_additional_attributes detects physical interface" do
    result = parser.send(:set_additional_attributes, {}, 'eth0')
    refute result[:virtual]

    result = parser.send(:set_additional_attributes, {}, 'em1')
    refute result[:virtual]
  end

  test "#set_additional_attributes detects virtual interface (facter < v3.0)" do
    parser = get_parser(:vlans => '1,2')

    result = parser.send(:set_additional_attributes, {}, 'eth0_0')
    assert result[:virtual]
    assert_equal 'eth0', result[:attached_to]
    assert_equal '', result[:tag]
    refute result[:bridge]

    result = parser.send(:set_additional_attributes, {}, 'eth0_1')
    assert result[:virtual]
    assert_equal 'eth0', result[:attached_to]
    assert_equal '1', result[:tag]
    refute result[:bridge]

    result = parser.send(:set_additional_attributes, {}, 'eth0_2')
    assert result[:virtual]
    assert_equal 'eth0', result[:attached_to]
    assert_equal '2', result[:tag]
    refute result[:bridge]

    result = parser.send(:set_additional_attributes, {}, 'eth0_4')
    assert result[:virtual]
    assert_equal 'eth0', result[:attached_to]
    assert_equal '', result[:tag]
    refute result[:bridge]

    result = parser.send(:set_additional_attributes, {}, 'eth0.101')
    assert result[:virtual]
    assert_equal 'eth0', result[:attached_to]
    assert_equal '101', result[:tag]
    refute result[:bridge]
  end

  test "#set_additional_attributes detects virtual interface facter >= v3.0" do
    result = parser.send(:set_additional_attributes, {}, 'eth0.100')
    assert result[:virtual]
    assert_equal 'eth0', result[:attached_to]
    assert_equal '100', result[:tag]
    refute result[:bridge]

    result = parser.send(:set_additional_attributes, {}, 'eth0:1')
    assert result[:virtual]
    assert_equal 'eth0', result[:attached_to]
    assert_equal '', result[:tag]
    refute result[:bridge]

    result = parser.send(:set_additional_attributes, {}, 'bond0.100')
    assert result[:virtual]
    assert_equal 'bond0', result[:attached_to]
    assert_equal '100', result[:tag]
    refute result[:bridge]

    result = parser.send(:set_additional_attributes, {}, 'bond0:1')
    assert result[:virtual]
    assert_equal 'bond0', result[:attached_to]
    assert_equal '', result[:tag]
    refute result[:bridge]

    result = parser.send(:set_additional_attributes, {}, 'eth0.100:1')
    assert result[:virtual]
    assert_equal 'eth0.100', result[:attached_to]
    assert_equal '', result[:tag]
    refute result[:bridge]

    result = parser.send(:set_additional_attributes, {}, 'bond0.100:1')
    assert result[:virtual]
    assert_equal 'bond0.100', result[:attached_to]
    assert_equal '', result[:tag]
    refute result[:bridge]
  end

  test "#set_additional_attributes detects bridged" do
    result = parser.send(:set_additional_attributes, {}, 'br0')
    assert result[:virtual]
    assert_empty result[:attached_to]
    assert_empty result[:tag]
    assert result[:bridge]

    result = parser.send(:set_additional_attributes, {}, 'virbr0')
    assert result[:virtual]
    assert_empty result[:attached_to]
    assert_empty result[:tag]
    assert result[:bridge]
  end

  context "parser tests involving hosts" do
    setup do
      @host = FactoryBot.build_stubbed(:host)
    end

    test "#suggested_primary_interface detects primary interface using DNS" do
      parser.stubs(:interfaces).returns({
        'br0' => {'ipaddress' => '30.0.0.30', 'macaddress' => '00:00:00:00:00:30'},
        'em1' => {'ipaddress' => '10.0.0.10', 'macaddress' => '00:00:00:00:00:10'},
        'em2' => {'ipaddress' => '12.0.0.12', 'macaddress' => '00:00:00:00:00:12'},
        'bond0' => {'ipaddress' => '15.0.0.15', 'macaddress' => '00:00:00:00:00:15'},
      }.with_indifferent_access)

      Resolv::DNS.any_instance.stubs(:getnames).returns([])
      Resolv::DNS.any_instance.expects(:getnames).with('12.0.0.12').returns([host.name])
      found = parser.suggested_primary_interface(host)
      assert_equal 'em2', found.first
      assert_equal '12.0.0.12', found.last[:ipaddress]
      assert_equal '00:00:00:00:00:12', found.last[:macaddress]
    end

    test "#suggested_primary_interface primary interface detection falls back to physical with ip and mac" do
      parser.stubs(:interfaces).returns({
        'br0' => {'ipaddress' => '30.0.0.30', 'macaddress' => '00:00:00:00:00:30'},
        'em0' => {'ipaddress' => '', 'macaddress' => ''},
        'em1' => {'ipaddress' => '10.0.0.10', 'macaddress' => '00:00:00:00:00:10'},
        'em2' => {'ipaddress' => '12.0.0.12', 'macaddress' => '00:00:00:00:00:12'},
        'bond0' => {'ipaddress' => '15.0.0.15', 'macaddress' => '00:00:00:00:00:15'},
      }.with_indifferent_access)

      Resolv::DNS.any_instance.stubs(:getnames).returns([])
      found = parser.suggested_primary_interface(host)
      assert_equal 'em1', found.first
      assert_equal '10.0.0.10', found.last[:ipaddress]
      assert_equal '00:00:00:00:00:10', found.last[:macaddress]
    end

    test "#suggested_primary_interface primary interface detection falls back to first with ip and mac if no physical" do
      parser.stubs(:interfaces).returns({
        'bond1' => {'ipaddress' => '', 'macaddress' => ''},
        'bond0' => {'ipaddress' => '15.0.0.15', 'macaddress' => '00:00:00:00:00:15'},
        'br0' => {'ipaddress' => '30.0.0.30', 'macaddress' => '00:00:00:00:00:30'},
      }.with_indifferent_access)

      Resolv::DNS.any_instance.stubs(:getnames).returns([])
      found = parser.suggested_primary_interface(host)
      assert_equal 'bond0', found.first
      assert_equal '15.0.0.15', found.last[:ipaddress]
      assert_equal '00:00:00:00:00:15', found.last[:macaddress]
    end

    test "#suggested_primary_interface primary interface detection falls back to first with ip and mac" do
      parser.stubs(:interfaces).returns({
        'br1'   => { 'ipaddress' => '',          'macaddress' => ''},
        'br0'   => { 'ipaddress' => '30.0.0.30', 'macaddress' => '00:00:00:00:00:30'},
      }.with_indifferent_access)

      Resolv::DNS.any_instance.stubs(:getnames).returns([])
      found = parser.suggested_primary_interface(host)
      assert_equal 'br0', found.first
      assert_equal '30.0.0.30', found.last[:ipaddress]
      assert_equal '00:00:00:00:00:30', found.last[:macaddress]
    end

    test "#suggested_primary_interface primary interface detection falls back to first if no other option" do
      parser.stubs(:interfaces).returns({
        'br1' => {'ipaddress' => '', 'macaddress' => ''},
        'br0' => {'ipaddress' => '', 'macaddress' => ''},
      }.with_indifferent_access)

      Resolv::DNS.any_instance.stubs(:getnames).returns([])
      found = parser.suggested_primary_interface(host)
      assert_equal 'br1', found.first
      assert_equal '', found.last[:ipaddress]
      assert_equal '', found.last[:macaddress]
    end
  end

  def get_parser(facts = {})
    FactParser.new(facts)
  end
end
