require "test_helper"

class PuppetFactsParserTest < ActiveSupport::TestCase
  attr_reader :importer

  def setup
    @importer = PuppetFactParser.new facts
    User.current = users :admin
  end

  test "should return list of interfaces" do
    assert importer.interfaces.present?
    assert_not_nil importer.suggested_primary_interface(FactoryGirl.create(:host))
    assert importer.interfaces.keys.include?(importer.suggested_primary_interface(FactoryGirl.create(:host)).first)
  end

  test "should parse virtual interfaces as vlan interfaces" do
    parser = PuppetFactParser.new({'interfaces' => 'eth0_0', 'ipaddress_eth0_0' => '192.168.0.1'})
    assert_equal 'eth0.0', parser.interfaces.keys.first
    assert_equal '192.168.0.1', parser.interfaces['eth0.0']['ipaddress']
  end

  test "should return an os" do
    assert_kind_of Operatingsystem, importer.operatingsystem
  end

  test "should raise on an invalid os" do
    @importer = PuppetFactParser.new({})
    assert_raise ::Foreman::Exception do
      importer.operatingsystem
    end
  end
  test "should return an env" do
    assert_kind_of Environment, importer.environment
  end

  test "should return an arch" do
    assert_kind_of Architecture, importer.architecture
  end

  test "should return a model" do
    assert_kind_of Model, importer.model
  end

  test "should return a domain" do
    assert_kind_of Domain, importer.domain
  end

  test "should make non-numeric os version strings into numeric" do
    @importer = PuppetFactParser.new({'operatingsystem' => 'AnyOS', 'operatingsystemrelease' => '1&2.3y4'})
    data = importer.operatingsystem
    assert_equal '12', data.major
    assert_equal '34', data.minor
  end

  test "should allow OS version minor component to be nil" do
    @importer = PuppetFactParser.new({'operatingsystem' => 'AnyOS', 'operatingsystemrelease' => '6'})
    data = importer.operatingsystem
    assert_equal "AnyOS 6", data.to_s
    assert_equal '6', data.major
    assert_empty data.minor
  end

  test "release_name should be nil when lsbdistcodename isn't set on Debian" do
    @importer = PuppetFactParser.new(debian_facts.delete_if { |k, v| k == "lsbdistcodename" })
    assert_equal nil, @importer.operatingsystem.release_name
  end

  test "should set os.release_name to the lsbdistcodename fact on Debian" do
    @importer = PuppetFactParser.new(debian_facts)
    assert_equal 'wheezy', @importer.operatingsystem.release_name
  end

  test "should not set os.release_name to the lsbdistcodename on non-Debian OS" do
    assert_not_equal 'Santiago', @importer.operatingsystem.release_name
  end

  test "should set description field from lsbdistdescription" do
    assert_equal "RHEL Server 6.2", @importer.operatingsystem.description
  end

  test "should not alter description field if already set" do
    # Need to instantiate @importer once with normal facts
    assert @importer.operatingsystem.present?
    # Now re-import with a different description
    facts_with_desc = facts.merge({:lsbdistdescription => "A different string"})
    @importer = PuppetFactParser.new facts_with_desc
    assert_equal "RHEL Server 6.2", @importer.operatingsystem.description
  end

  test "should set description correctly for SLES" do
    @importer = PuppetFactParser.new(sles_facts)
    assert_equal 'SLES 11 SP3', @importer.operatingsystem.description
  end

  test "should not set description if lsbdistdescription is missing" do
    facts.delete('lsbdistdescription')
    @importer = PuppetFactParser.new(facts)
    refute @importer.operatingsystem.description
  end

  test "should set os.major and minor correctly from AIX facts" do
    @importer = PuppetFactParser.new(aix_facts)
    assert_equal 'AIX', @importer.operatingsystem.family
    assert_equal '6100', @importer.operatingsystem.major
    assert_equal '0604', @importer.operatingsystem.minor
  end

  test 'should handle FreeBSD rolling releases correctly' do
    @importer = PuppetFactParser.new(freebsd_stable_facts)
    assert_equal '10', @importer.operatingsystem.major
    assert_equal '1', @importer.operatingsystem.minor
  end

  test 'should handle FreeBSD patch releases correctly' do
    @importer = PuppetFactParser.new(freebsd_patch_facts)
    assert_equal '10', @importer.operatingsystem.major
    assert_equal '1', @importer.operatingsystem.minor
  end

  test "#get_interfaces" do
    host = FactoryGirl.create(:host, :hostgroup => FactoryGirl.create(:hostgroup))
    parser = get_parser(host.facts_hash)

    assert_empty parser.send(:get_interfaces)

    interfaces = FactoryGirl.create(:fact_value,
                                    :fact_name => FactoryGirl.create(:fact_name, :name => 'interfaces'),
                                    :host => host,
                                    :value => '')
    parser = get_parser(host.facts_hash)
    assert_empty parser.send(:get_interfaces)

    interfaces.update_attribute :value, 'lo,eth0,eth0.0,eth1'
    parser = get_parser(host.facts_hash)
    %w(lo eth0 eth0.0 eth1).each do |interface|
      assert_includes parser.send(:get_interfaces), interface
    end
  end

  test "#get_facts_for_interface(interface)" do
    host = FactoryGirl.create(:host, :hostgroup => FactoryGirl.create(:hostgroup))
    FactoryGirl.create(:fact_value,
                       :fact_name => FactoryGirl.create(:fact_name, :name => 'link_eth0'),
                       :host => host,
                       :value => 'true')
    FactoryGirl.create(:fact_value,
                       :fact_name => FactoryGirl.create(:fact_name, :name => 'macaddress_eth0'),
                       :host => host,
                       :value => '00:00:00:00:00:ab')
    FactoryGirl.create(:fact_value,
                       :fact_name => FactoryGirl.create(:fact_name, :name => 'ipaddress_eth0'),
                       :host => host,
                       :value => '192.168.0.1')
    FactoryGirl.create(:fact_value,
                       :fact_name => FactoryGirl.create(:fact_name, :name => 'custom_fact_eth0'),
                       :host => host,
                       :value => 'custom_value')
    FactoryGirl.create(:fact_value,
                       :fact_name => FactoryGirl.create(:fact_name, :name => 'link_eth0_0'),
                       :host => host,
                       :value => 'false')
    FactoryGirl.create(:fact_value,
                       :fact_name => FactoryGirl.create(:fact_name, :name => 'macaddress_eth0_0'),
                       :host => host,
                       :value => '00:00:00:00:00:cd')
    FactoryGirl.create(:fact_value,
                       :fact_name => FactoryGirl.create(:fact_name, :name => 'ipaddress_eth0_0'),
                       :host => host,
                       :value => '192.168.0.2')
    FactoryGirl.create(:fact_value,
                       :fact_name => FactoryGirl.create(:fact_name, :name => 'custom_fact_eth0_0'),
                       :host => host,
                       :value => 'another_value')
    parser = get_parser(host.facts_hash)

    result = parser.send(:get_facts_for_interface, 'eth0')
    assert_equal 'true', result[:link]
    assert_equal '00:00:00:00:00:ab', result['macaddress']
    assert_equal '192.168.0.1', result['ipaddress']
    assert_equal 'custom_value', result['custom_fact']
  end

  test "#ipmi_interface" do
    host = FactoryGirl.create(:host, :hostgroup => FactoryGirl.create(:hostgroup))
    parser = get_parser(host.facts_hash)

    result = parser.ipmi_interface
    assert_equal({}, result)

    FactoryGirl.create(:fact_value,
                       :fact_name => FactoryGirl.create(:fact_name, :name => 'ipmi_ipaddress'),
                       :host => host,
                       :value => '192.168.0.1')
    FactoryGirl.create(:fact_value,
                       :fact_name => FactoryGirl.create(:fact_name, :name => 'ipmi_custom'),
                       :host => host,
                       :value => 'custom_value')
    parser = get_parser(host.facts_hash)

    result = parser.ipmi_interface
    assert result.present?
    assert_equal '192.168.0.1', result[:ipaddress]
    assert_equal 'custom_value', result['custom']
  end

  test "#interfaces with underscores are mapped correctly" do
    parser = get_parser({:interfaces => 'eth1_1,eth1_2,eth1,eth2',
                         :ipaddress_eth1_1 => '192.168.0.1',
                         :ipaddress_eth1_2 => '192.168.0.2',
                         :ipaddress_eth1 => '192.168.0.3',
                         :ipaddress_eth2 => '192.168.0.4'})
    assert_not_nil parser.interfaces['eth1.1']
    assert_equal '192.168.0.1', parser.interfaces['eth1.1'][:ipaddress]
    assert_not_nil parser.interfaces['eth1.2']
    assert_equal '192.168.0.2', parser.interfaces['eth1.2'][:ipaddress]
    assert_not_nil parser.interfaces['eth1']
    assert_equal '192.168.0.3', parser.interfaces['eth1'][:ipaddress]
    assert_not_nil parser.interfaces['eth2']
    assert_equal '192.168.0.4', parser.interfaces['eth2'][:ipaddress]
  end

  test "#interfaces are mapped case-insensitively and parses Windows LAN name" do
    parser = get_parser({:interfaces => 'Local_Area_Connection_2',
                         :ipaddress_local_area_connection_2 => '172.30.43.87',
                         :macaddress_local_area_connection_2 => '00:50:56:B7:69:F6',
                         :netmask_local_area_connection_2 => '255.255.255.0',
                         :network_local_area_connection_2 => '172.30.43.0'})
    assert_not_nil parser.interfaces['local_area_connection_2']
    assert_equal '172.30.43.87', parser.interfaces['local_area_connection_2'][:ipaddress]
    assert_equal '255.255.255.0', parser.interfaces['local_area_connection_2'][:netmask]
    assert_equal '00:50:56:B7:69:F6', parser.interfaces['local_area_connection_2'][:macaddress]
    assert_equal '172.30.43.0', parser.interfaces['local_area_connection_2'][:network]
  end

  private

  def get_parser(facts)
    PuppetFactParser.new(facts)
  end

  def facts
    #  return the equivalent of Facter.to_hash
    @json ||= JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + "/facts.json")))['facts']
  end

  def debian_facts
    JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + '/facts_debian.json')))['facts']
  end

  def sles_facts
    JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + '/facts_sles.json')))['facts']
  end

  def aix_facts
    JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + '/facts_aix.json')))['facts']
  end

  def freebsd_stable_facts
    JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + '/facts_freebsd_stable.json')))['facts']
  end

  def freebsd_patch_facts
    JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + '/facts_freebsd_patch.json')))['facts']
  end
end
