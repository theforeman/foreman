require 'test_helper'

def valid_interfaces_names
  [
    RFauxFactory.gen_alpha(1).downcase,
    RFauxFactory.gen_alpha(rand(1..255)).downcase,
    RFauxFactory.gen_alphanumeric(rand(1..255)).downcase,
    RFauxFactory.gen_numeric_string(rand(1..255)).downcase,
    RFauxFactory.gen_alpha(255).downcase,
  ]
end

def invalid_interfaces_names
  [
    RFauxFactory.gen_alpha(256).downcase,
    RFauxFactory.gen_alphanumeric(256).downcase,
    RFauxFactory.gen_numeric_string(256).downcase,
    RFauxFactory.gen_cjk,
    RFauxFactory.gen_cyrillic,
    RFauxFactory.gen_html,
    RFauxFactory.gen_latin1,
    RFauxFactory.gen_utf8,
  ]
end

class Nic::BaseTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
  end

  should allow_values('00:50:56:84:4e:e3', '00:01:44:55:66:77', '72:00:03:bd:3b:70').
    for(:mac)

  should_not allow_values('13-61-f1-de-71-73', '01-00-CC-CC-DD-DD', 'ff-ff-ff-ff-ff-ff').
    for(:mac)

  test '#host_managed? returns false if interface does not have a host' do
    nic = FactoryBot.build_stubbed(:nic_base)
    nic.host = nil
    refute nic.host_managed?
  end

  test 'should create with multiple valid names' do
    host = FactoryBot.build_stubbed(:host, :managed)
    valid_interfaces_names.each do |name|
      nic = FactoryBot.build_stubbed(:nic_managed, :name => name, :host => host)
      assert nic.valid?, "Can't create nic with valid name #{name}"
    end
  end

  test 'should update with multiple valid names' do
    host = FactoryBot.create(:host, :managed)
    valid_interfaces_names.each do |name|
      name = name[1..254 - host.domain.name.length] if name.length + host.domain.name.length > 254
      host.interfaces.first.name = name
      assert host.valid?, "Can't update nic with valid name #{name}.#{host.domain.name}"
    end
  end

  test 'should not create with multiple invalid names' do
    host = FactoryBot.build_stubbed(:host, :managed)
    invalid_interfaces_names.each do |name|
      nic = FactoryBot.build_stubbed(:nic_managed, :name => name, :host => host)
      refute nic.valid?, "Can create nic with invalid name #{name}"
      assert_includes nic.errors.keys, :name
    end
  end

  test 'should not update with multiple invalid names' do
    host = FactoryBot.create(:host, :managed)
    invalid_interfaces_names.each do |name|
      host.interfaces.first.name = name
      refute host.valid?, "Can update nic with valid name #{name}"
      assert host.interfaces.any? { |i| i.errors[:name].present? }
    end
  end

  test '#host_managed? returns false if associated host is unmanaged' do
    nic = FactoryBot.build_stubbed(:nic_base)
    nic.host = FactoryBot.build_stubbed(:host)
    nic.host.managed = false
    refute nic.host_managed?
  end

  test '#host_managed? returns false in non-unattended mode' do
    nic = FactoryBot.build_stubbed(:nic_base)
    nic.host = FactoryBot.build_stubbed(:host)
    nic.host.managed = true
    original, SETTINGS[:unattended] = SETTINGS[:unattended], false
    refute nic.host_managed?
    SETTINGS[:unattended] = original
  end

  test '#host_managed? return true if associated host is managed in unattended mode' do
    nic = FactoryBot.build_stubbed(:nic_base)
    nic.host = FactoryBot.build_stubbed(:host)
    nic.host.managed = true
    original, SETTINGS[:unattended] = SETTINGS[:unattended], true
    assert nic.host_managed?
    SETTINGS[:unattended] = original
  end

  test 'nic requires a host' do
    nic = FactoryBot.build_stubbed(:nic_base)
    refute nic.valid?, "Can't be valid without a host: #{nic.errors.messages}"
    assert_includes nic.errors.keys, :host
  end

  test 'nic is invalid when subnet types are wrong' do
    nic = FactoryBot.build_stubbed(:nic_base)
    subnetv4 = Subnet::Ipv4.new
    subnetv6 = Subnet::Ipv6.new

    nic.subnet = subnetv6
    nic.subnet6 = subnetv4

    refute nic.valid?, "Can't be valid with invalid subnet types: #{nic.errors.messages}"
    assert_includes nic.errors.keys, :subnet
    assert_includes nic.errors.keys, :subnet6
  end

  context '#matches_subnet?' do
    let(:subnet) { FactoryBot.build_stubbed(:subnet_ipv4, :network => '10.10.10.0') }
    let(:nic) { FactoryBot.build_stubbed(:nic_base, :ip => '10.10.10.1', :subnet => subnet) }

    test 'is true when subnet contains ip' do
      assert nic.matches_subnet?(:ip, :subnet)
    end

    test 'is false when subnet does not contain ip' do
      nic.ip = '192.168.1.1'
      refute nic.matches_subnet?(:ip, :subnet)
    end
  end

  context 'there is already an interface with a MAC and IP' do
    let(:host) { FactoryBot.create(:host, :managed, :with_ipv6) }

    describe 'creation of another nic with already used MAC and IP' do
      let(:nic) do
        nic = host.interfaces.build(:mac => host.mac, :managed => true, :type => 'Nic::Managed')
        nic.ip = host.ip
        nic.ip6 = host.ip6
        nic
      end

      test 'it is invalid because of conflicting mac' do
        refute nic.valid?
        assert nic.errors.has_key?(:mac)
        assert nic.errors.has_key?(:ip)
        assert nic.errors.has_key?(:ip6)
      end

      test 'it is valid if conflicting interface is on same host and is marked for destruction' do
        host.primary_interface.mark_for_destruction
        assert nic.valid?, "Nic is not valid: #{nic.errors.messages}"
      end

      test 'it is valid if conflicting interface is virtual' do
        host.primary_interface.update_attribute :virtual, true
        nic.ip = nil
        nic.ip6 = nil
        assert nic.valid?, "Nic is not valid: #{nic.errors.messages}"
      end

      test 'it is valid if conflicting interface is unmanaged' do
        host.primary_interface.update_attribute :managed, false
        nic.ip = nil
        nic.ip6 = nil
        assert nic.valid?, "Nic is not valid: #{nic.errors.messages}"
      end
    end

    describe 'creation of another nic with the same name' do
      let(:nic) { host.interfaces.build(:mac => next_mac(host.mac), :managed => true, :type => 'Nic::Managed') }

      context 'the domain is different' do
        test 'it is valid' do
          nic.name = host.shortname
          assert_nil nic.domain
          assert nic.valid?
        end
      end

      context 'the domain is the same' do
        before do
          nic.name = host.name
          nic.domain = host.domain
        end

        test 'it is invalid because of the name attribute' do
          refute nic.valid?
          assert nic.errors.has_key?(:name)
        end

        test 'it is valid if conflicting interface is on same host and is marked for destruction' do
          host.primary_interface.mark_for_destruction
          assert nic.valid?
        end
      end
    end

    describe 'creation of another nic with already used identifier' do
      let(:nic) do
        nic = host.interfaces.build(:managed => true, :type => 'Nic::Managed')
        nic.identifier = host.primary_interface.identifier
        nic
      end

      let(:nic2) do
        host.interfaces.build(:managed => true, :type => 'Nic::Managed')
      end

      test 'it is invalid because of conflicting identifier' do
        refute nic.valid?
        assert nic.errors.has_key?(:identifier)
      end

      test 'it ignores empty identifiers' do
        nic.mac = '00:11:11:22:22:33'
        nic2.mac = '00:11:11:22:22:34'
        nic.identifier = nic2.identifier = ''
        nic.save
        # nic2.save

        assert nic.valid?
        assert nic2.valid?
      end
    end
  end

  describe 'normalization' do
    let(:host) { FactoryBot.build_stubbed(:host) }
    let(:nic) { FactoryBot.build_stubbed(:nic_base, :host => host) }

    test 'it normalizes ipv4 address' do
      nic.ip = '001.001.001.001'
      assert_equal '1.1.1.1', nic.ip
    end

    test 'it normalizes ipv6 address' do
      nic.ip6 = '2001:0db8:0000:0000:0000::0001'
      assert_equal '2001:db8::1', nic.ip6
    end

    test 'it normalizes mac' do
      nic.mac = 'aa-bb-cc-dd-ee-ff'
      assert_valid nic # normalization is done before validation
      assert_equal 'aa:bb:cc:dd:ee:ff', nic.mac
    end
  end

  test '#children_mac_addresses defaults to empty array' do
    nic = FactoryBot.build_stubbed(:nic_base)
    assert_equal [], nic.children_mac_addresses
  end

  describe 'MAC validation' do
    let(:subnet) { FactoryBot.build_stubbed(:subnet_ipv4, :network => '10.10.10.0') }
    let(:subnetv6) { FactoryBot.build_stubbed(:subnet_ipv6, :network => '2001:db8::') }
    let(:host) { FactoryBot.build_stubbed(:host, :managed) }

    test 'MAC address is validated if subnet is set' do
      nic = FactoryBot.build_stubbed(:nic_managed, :subnet => subnet, :host => host)
      nic.mac = ""
      refute_valid nic
      assert_includes nic.errors.keys, :mac
      nic.mac = "00:00:00:00:00:00"
      assert_valid nic
    end

    test 'MAC address is validated if subnet6 is set' do
      nic = FactoryBot.build_stubbed(:nic_managed, :subnet6 => subnetv6, :host => host)
      nic.mac = ""
      refute_valid nic
      assert_includes nic.errors.keys, :mac
      nic.mac = "00:00:00:00:00:00"
      assert_valid nic
    end

    test 'MAC address is validated if provisioning is set' do
      nic = host.primary_interface
      nic.domain = domains(:mydomain)
      nic.mac = ""
      refute_valid nic
      assert_includes nic.errors.keys, :mac
      nic.mac = "00:00:00:00:00:00"
      assert_valid nic
    end

    test 'MAC address is not checked if no subnet or provisioning' do
      nic = FactoryBot.build_stubbed(:nic_managed, :host => host)
      nic.mac = ""
      assert_valid nic
      nic.mac = "00:00:00:00:00:00"
      assert_valid nic
    end
  end
end
