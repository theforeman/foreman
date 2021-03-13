require "test_helper"

class PuppetFactsParserTest < ActiveSupport::TestCase
  attr_reader :importer

  def setup
    @importer = PuppetFactParser.new facts
    User.current = users :admin
  end

  test "should return list of interfaces" do
    assert importer.interfaces.present?
    assert_not_nil importer.suggested_primary_interface(FactoryBot.build(:host))
    assert importer.interfaces.key?(importer.suggested_primary_interface(FactoryBot.build(:host)).first)
  end

  test "should parse virtual interfaces as vlan interfaces when facter < v3.0" do
    parser = PuppetFactParser.new(facterversion: '2.8.9',
                                  interfaces: 'eth0_0',
                                  ipaddress_eth0_0: '192.168.0.1')
    assert_equal 'eth0.0', parser.interfaces.keys.first
    assert_equal '192.168.0.1', parser.interfaces['eth0.0']['ipaddress']
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

  describe '#operatingsystem' do
    let(:os) { importer.operatingsystem }

    test "should return an os" do
      assert_kind_of Operatingsystem, os
      assert_os_idempotent
    end

    test "should raise on an invalid os" do
      @importer = PuppetFactParser.new({})
      assert_raise ::Foreman::Exception do
        importer.operatingsystem
      end
    end

    test "should make non-numeric os version strings into numeric" do
      @importer = PuppetFactParser.new({'operatingsystem' => 'AnyOS', 'operatingsystemrelease' => '1&2.3y4'})
      assert_equal '12', os.major
      assert_equal '34', os.minor
      assert_os_idempotent
    end

    test "should allow OS version minor component to be nil" do
      @importer = PuppetFactParser.new({'operatingsystem' => 'AnyOS', 'operatingsystemrelease' => '6'})
      assert_equal "AnyOS 6", os.to_s
      assert_equal '6', os.major
      assert_empty os.minor
      assert_os_idempotent
    end

    test "release_name should be unknown when lsbdistcodename isn't set on Debian" do
      @importer = PuppetFactParser.new(debian_facts.delete_if { |k, v| k == "lsbdistcodename" })
      assert_equal 'unknown', os.release_name
      assert_os_idempotent
    end

    test "should set os.release_name to the lsbdistcodename fact on Debian" do
      @importer = PuppetFactParser.new(debian_facts)
      assert_equal 'wheezy', os.release_name
      assert_os_idempotent
    end

    test "should not alter lsbdistcodename and set it to unknown" do
      @importer = PuppetFactParser.new(debian_facts)
      assert_equal 'wheezy', os.release_name
      first_os = @importer.operatingsystem
      assert first_os.present?
      @importer = PuppetFactParser.new(debian_facts.delete_if { |k, v| k == "lsbdistcodename" })
      second_os = @importer.operatingsystem
      assert_equal 'wheezy', os.release_name
      assert_equal first_os, second_os
    end

    test "should set os.release_name to the lsbdistcodename fact on Debian facter v3" do
      @importer = PuppetFactParser.new(debian_facts_v3)
      assert_equal 'Debian', os.name
      assert_equal 'Debian 10.3', os.title
      assert_equal 'Debian 10.3', os.description
      assert_equal '10', os.major
      assert_equal '3', os.minor
      assert_equal 'buster', os.release_name
    end

    test "should not set os.release_name to the lsbdistcodename on non-Debian OS" do
      assert_not_equal 'Santiago', os.release_name
    end

    test "should set description field from lsbdistdescription" do
      assert_equal "RHEL Server 6.2", os.description
    end

    test "should not mix Workstation with Server on RHEL7" do
      @importer = PuppetFactParser.new(rhel_7_workstation_facts)
      first_os = @importer.operatingsystem
      assert first_os.present?
      assert_equal "RedHat_Workstation", first_os.name

      @importer = PuppetFactParser.new(rhel_7_server_facts)
      first_os = @importer.operatingsystem
      assert first_os.present?
      assert_equal "RedHat", first_os.name
    end

    test "should not alter description field if already set" do
      # Need to instantiate @importer once with normal facts
      first_os = @importer.operatingsystem
      assert first_os.present?
      # Now re-import with a different description
      facts_with_desc = facts.merge({:lsbdistdescription => "A different string"})
      @importer = PuppetFactParser.new facts_with_desc
      second_os = @importer.operatingsystem
      assert_equal "RHEL Server 6.2", second_os.description
      assert_equal first_os, second_os
    end

    test "should set description correctly for SLES" do
      @importer = PuppetFactParser.new(sles_facts)
      assert_equal 'SLES 11 SP3', os.description
      assert_os_idempotent
    end

    test "should set version correctly for PSBM" do
      @importer = PuppetFactParser.new("operatingsystem" => "PSBM",
                                       "operatingsystemrelease" => "2.6.32-042stab111.11")
      assert_equal '2', os.major
      assert_equal '6', os.minor
      assert_os_idempotent
    end

    test "should not set description if lsbdistdescription is missing" do
      facts.delete('lsbdistdescription')
      @importer = PuppetFactParser.new(facts)
      refute os.description
      assert_os_idempotent
    end

    test 'should accept y.z minor version' do
      FactoryBot.build(:operatingsystem, name: "CentOS",
                                           major: "7",
                                           minor: "2.1511",
                                           description: "CentOS Linux 7.2.1511")
      @importer = PuppetFactParser.new("operatingsystem" => "CentOS",
                                       "lsbdistdescription" => "CentOS Linux release 7.2.1511 (Core) ",
                                       "operatingsystemrelease" => "7.2.1511")
      assert_valid os
      assert_os_idempotent
    end

    test "should set os.major and minor correctly from AIX facts" do
      @importer = PuppetFactParser.new(aix_facts)
      assert_equal 'AIX', os.family
      assert_equal '6100', os.major
      assert_equal '0604', os.minor
      assert_os_idempotent
    end

    test 'should handle FreeBSD rolling releases correctly' do
      @importer = PuppetFactParser.new(freebsd_stable_facts)
      assert_equal '10', os.major
      assert_equal '1', os.minor
      assert_os_idempotent
    end

    test 'should handle FreeBSD patch releases correctly' do
      @importer = PuppetFactParser.new(freebsd_patch_facts)
      assert_equal '10', os.major
      assert_equal '1', os.minor
      assert_os_idempotent
    end

    test "should set os.major and minor correctly from Solaris 10 facts" do
      @importer = PuppetFactParser.new(read_json_fixture('facts/solaris10.json'))
      os = @importer.operatingsystem
      assert_equal 'Solaris', os.family
      assert_equal '10', os.major
      assert_equal '9', os.minor
      assert_os_idempotent
    end
  end

  describe "#facterversion" do
    test "returns an array of integers" do
      parser = PuppetFactParser.new(facterversion: '3.2.1')
      assert_equal [3, 2, 1], parser.send(:facterversion)
    end

    test "returns an array of integers when only major version is reported" do
      parser = PuppetFactParser.new(facterversion: '3')
      assert_equal [3], parser.send(:facterversion)
    end

    test "returns and empy array when facterversion is not reported" do
      parser = PuppetFactParser.new({})
      result = parser.send(:facterversion)
      assert_instance_of Array, result
      assert_empty result
    end
  end

  describe "#use_legacy_facts?" do
    test 'returns false when facterversion >= 3' do
      parser = PuppetFactParser.new(facterversion: '3.2.1')
      assert_not parser.send(:use_legacy_facts?)
    end

    test 'returns true when facterversion < 3' do
      parser = PuppetFactParser.new(facterversion: '2.4.5')
      assert parser.send(:use_legacy_facts?)
    end

    test 'returns true when facterversion is not reported' do
      parser = PuppetFactParser.new({})
      assert parser.send(:use_legacy_facts?)
    end
  end

  test "#get_interfaces when facter < v3.0" do
    host = FactoryBot.build(:host, :hostgroup => FactoryBot.build(:hostgroup))
    parser = get_parser(host.facts_hash.merge(facterversion: '2.7.9'))

    assert_empty parser.send(:get_interfaces)

    interfaces = FactoryBot.build(:fact_value,
      :fact_name => FactoryBot.build(:fact_name, :name => 'interfaces'),
      :host => host,
      :value => '')
    parser = get_parser(host.facts_hash.merge(facterversion: '2.7.9'))
    assert_empty parser.send(:get_interfaces)

    interfaces.update_attribute :value, 'lo,eth0,eth0.0,eth1'
    parser = get_parser(host.facts_hash.merge(facterversion: '2.7.9'))
    %w(lo eth0 eth0.0 eth1).each do |interface|
      assert_includes parser.send(:get_interfaces), interface
    end
  end

  test "#get_interfaces when facter >= v3.0" do
    parser = get_parser(facterversion: '3.1.2')
    assert_empty parser.send(:get_interfaces)

    parser = get_parser(facterversion: '3.1.2',
                       networking: {})
    assert_empty parser.send(:get_interfaces)

    parser = get_parser(facterversion: '3.1.2',
                        networking: { interfaces: {} })
    assert_empty parser.send(:get_interfaces)

    parser = get_parser(facterversion: '3.1.2',
                        networking: { interfaces: nil})
    assert_empty parser.send(:get_interfaces)

    parser = get_parser(structured_networking_facts)
    %w(bond0 em1 em2 eth0 eth1:1 eth1.2 Ethernet_0).each do |interface|
      assert_includes parser.send(:get_interfaces), interface
    end
  end

  test "#get_facts_for_interface(interface) uses legacy facts when facter < v3.0" do
    host = FactoryBot.build(:host, :hostgroup => FactoryBot.build(:hostgroup))
    FactoryBot.create(:fact_value,
      :fact_name => FactoryBot.create(:fact_name, :name => 'link_eth0'),
      :host => host,
      :value => 'true')
    FactoryBot.create(:fact_value,
      :fact_name => FactoryBot.create(:fact_name, :name => 'macaddress_eth0'),
      :host => host,
      :value => '00:00:00:00:00:ab')
    FactoryBot.create(:fact_value,
      :fact_name => FactoryBot.create(:fact_name, :name => 'ipaddress_eth0'),
      :host => host,
      :value => '192.168.0.1')
    FactoryBot.create(:fact_value,
      :fact_name => FactoryBot.create(:fact_name, :name => 'custom_fact_eth0'),
      :host => host,
      :value => 'custom_value')
    FactoryBot.create(:fact_value,
      :fact_name => FactoryBot.create(:fact_name, :name => 'link_eth0_0'),
      :host => host,
      :value => 'false')
    FactoryBot.create(:fact_value,
      :fact_name => FactoryBot.create(:fact_name, :name => 'macaddress_eth0_0'),
      :host => host,
      :value => '00:00:00:00:00:cd')
    FactoryBot.create(:fact_value,
      :fact_name => FactoryBot.create(:fact_name, :name => 'ipaddress_eth0_0'),
      :host => host,
      :value => '192.168.0.2')
    FactoryBot.create(:fact_value,
      :fact_name => FactoryBot.create(:fact_name, :name => 'custom_fact_eth0_0'),
      :host => host,
      :value => 'another_value')
    parser = get_parser(host.facts_hash.merge(facterversion: '2.7.9'))

    result = parser.send(:get_facts_for_interface, 'eth0')
    assert_equal 'true', result[:link]
    assert_equal '00:00:00:00:00:ab', result['macaddress']
    assert_equal '192.168.0.1', result['ipaddress']
    assert_equal 'custom_value', result['custom_fact']
  end

  test "#get_facts_for_interface(interface) uses networking fact when facter >= v3.0" do
    parser = get_parser(structured_networking_facts)
    result = parser.send(:get_facts_for_interface, 'eth0')
    assert_equal 'custom_value', result['custom_fact']
    assert_equal '00:00:00:00:00:ab', result['macaddress']
    assert_equal 1500, result['mtu']
    assert_equal '192.168.0.1', result['ipaddress']
    assert_equal 'fe80::250:56ff:fea0:7e4a', result['ipaddress6']
    assert_equal '255.255.255.0', result['netmask']
    assert_equal 'ffff:ffff:ffff:ffff::', result['netmask6']
    assert_equal '192.168.0.0', result['network']
    assert_equal 'fe80::', result['network6']
  end

  test "#interfaces ignores legacy facts when facter >= v3.0" do
    parser = get_parser(structured_networking_facts.merge(
      interfaces: 'eth5',
      ipadress_eth3: '192.168.6.1',
      macaddress_eth3: '00:50:56:B7:69:F6',
      netmask_eth3: '255.255.254.0'
    ))

    assert_not_nil parser.interfaces['eth1:1']
    assert parser.interfaces.values.any? { |x| x[:ipaddress] == '192.168.0.1' }
    assert_nil parser.interfaces['eth5']
    assert_not parser.interfaces.values.any? { |x| x[:ipaddress] == '192.168.6.1' }
    assert_not parser.interfaces.values.any? { |x| x[:macaddress] == '00:50:56:B7:69:F6' }
    assert_not parser.interfaces.values.any? { |x| x[:netmask] == '255.255.254.0' }
  end

  test "#ipmi_interface" do
    host = FactoryBot.build(:host, :hostgroup => FactoryBot.build(:hostgroup))
    parser = get_parser(host.facts_hash)

    result = parser.ipmi_interface
    assert_equal({}, result)

    FactoryBot.create(:fact_value,
      :fact_name => FactoryBot.create(:fact_name, :name => 'ipmi_ipaddress'),
      :host => host,
      :value => '192.168.0.1')
    FactoryBot.create(:fact_value,
      :fact_name => FactoryBot.create(:fact_name, :name => 'ipmi_custom'),
      :host => host,
      :value => 'custom_value')
    parser = get_parser(host.facts_hash)

    result = parser.ipmi_interface
    assert result.present?
    assert_equal '192.168.0.1', result[:ipaddress]
    assert_equal 'custom_value', result['custom']
  end

  test "#interfaces with underscores are mapped correctly when facter < v3.0" do
    parser = get_parser({:facterversion => '2.7.9',
                         :interfaces => 'eth1_1,eth1_2,eth1,eth2',
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

  test "#interfaces are mapped case-insensitively and parses Windows LAN name when facter < v3.0" do
    parser = get_parser({:facterversion => '2.7.9',
                         :interfaces => 'Local_Area_Connection_2',
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

  test "#interfaces names are not mangled when facter >= v3.0" do
    parser = get_parser(structured_networking_facts)

    assert_not_nil parser.interfaces['eth1:1']
    assert_equal '192.168.0.3', parser.interfaces['eth1:1'][:ipaddress]
    assert_not_nil parser.interfaces['eth1.2']
    assert_equal '192.168.2.1', parser.interfaces['eth1.2'][:ipaddress]
    assert_not_nil parser.interfaces['Ethernet_0']
    assert_equal '192.168.120.1', parser.interfaces['Ethernet_0'][:ipaddress]
    assert_nil parser.interfaces['ethernet.0']
    assert_nil parser.interfaces['ethernet_0']
    assert_nil parser.interfaces['Ethernet.0']
    assert_nil parser.interfaces['eth1_1']
  end

  test "#test boot time based on uptime" do
    host = FactoryBot.build(:host, :hostgroup => FactoryBot.build(:hostgroup))
    freeze_time do
      parser = get_parser(host.facts_hash.merge({:uptime_seconds => (60 * 5).to_s}))
      assert_equal 5.minutes.ago.to_i, parser.boot_timestamp
    end
  end

  test '#test disks_total parsing correctly' do
    values = [
      {facts: example_v3_facts, disks_size: 256060514304},
      {facts: example_v4_facts, disks_size: 512121028608},
    ]

    values.each do |hash|
      parser = get_parser(hash[:facts])
      assert_equal hash[:disks_size], parser.disks_total
    end
  end

  private

  def get_parser(facts)
    PuppetFactParser.new(facts)
  end

  def facts
    #  return the equivalent of Facter.to_hash
    @json ||= read_json_fixture('facts/facts.json')['facts']
  end

  def debian_facts
    read_json_fixture('facts/facts_debian.json')['facts']
  end

  def debian_facts_v3
    read_json_fixture('facts/facts_v3_debian.json')
  end

  def rhel_7_workstation_facts
    read_json_fixture('facts/facts_rhel_7_workstation.json').with_indifferent_access
  end

  def rhel_7_server_facts
    read_json_fixture('facts/facts_rhel_7_server.json').with_indifferent_access
  end

  def sles_facts
    read_json_fixture('facts/facts_sles.json')['facts']
  end

  def aix_facts
    read_json_fixture('facts/facts_aix.json')['facts']
  end

  def freebsd_stable_facts
    read_json_fixture('facts/facts_freebsd_stable.json')['facts']
  end

  def freebsd_patch_facts
    read_json_fixture('facts/facts_freebsd_patch.json')['facts']
  end

  def structured_networking_facts
    read_json_fixture('facts/facts_structured_networking.json')['facts']
  end

  def example_v3_facts
    read_json_fixture('facts/example_3.14.16.json').with_indifferent_access
  end

  def example_v4_facts
    read_json_fixture('facts/example_4.0.52.json').with_indifferent_access
  end

  def assert_os_idempotent(previous_os = os)
    assert_equal previous_os, importer.operatingsystem, 'Different operating system returned on second call'
    assert_equal previous_os.attributes, importer.operatingsystem.attributes, 'Different operating system attributes set on second call'
  end
end
