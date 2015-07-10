require 'test_helper'

class NicTest < ActiveSupport::TestCase
  def setup
    disable_orchestration
    User.current = users :admin

    @nic = FactoryGirl.build(:nic_managed, :host => FactoryGirl.build(:host, :managed => true))
  end

  def teardown
    User.current = nil
  end

  test "should create simple interface" do
    i = Nic::Base.create! :mac => "cabbccddeeff", :host => FactoryGirl.create(:host)
    assert_equal "Nic::Base", i.class.to_s
  end

  test "type casting should return the correct class" do
    i = Nic::Base.create! :ip => "127.2.3.8", :mac => "babbccddeeff", :host => FactoryGirl.create(:host),
                          :type => "Nic::Interface"
    assert_equal "Nic::Interface", i.type
  end

  test "should fail on invalid mac" do
    i = Nic::Base.new :mac => "abccddeeff", :host => FactoryGirl.create(:host, :managed)
    assert !i.valid?
    assert i.errors.keys.include?(:mac)
  end

  test "should be valid with 64-bit mac address" do
    i = Nic::Base.new :mac => "babbccddeeff00112233445566778899aabbccdd", :host => FactoryGirl.create(:host)
    assert i.valid?
    assert !i.errors.keys.include?(:mac)
  end

  test "should fail on invalid dns name" do
    i = Nic::Managed.new :mac => "dabbccddeeff", :host => FactoryGirl.create(:host), :name => "invalid_dns_name"
    assert !i.valid?
    assert i.errors.keys.include?(:name)
  end

  test "should fix mac address" do
    interface = Nic::Base.create! :mac => "cabbccddeeff", :host => FactoryGirl.create(:host)
    assert_equal "ca:bb:cc:dd:ee:ff", interface.mac
  end

  test "should fix 64-bit mac address" do
    interface = Nic::Base.create! :mac => "babbccddeeff00112233445566778899aabbccdd", :host => FactoryGirl.create(:host)
    assert_equal "ba:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99:aa:bb:cc:dd", interface.mac
  end

  test "should fix ip address if a leading zero is used" do
    interface = Nic::Interface.create! :ip => "123.01.02.03", :mac => "dabbccddeeff", :host => FactoryGirl.create(:host)
    assert_equal "123.1.2.3", interface.ip
  end

  test "should delegate subnet attributes" do
    subnet = subnets(:two)
    domain = (subnet.domains.any? ? subnet.domains : subnet.domains << Domain.first).first
    interface = Nic::Managed.create! :ip => "2.3.4.127", :mac => "cabbccddeeff", :host => FactoryGirl.create(:host), :subnet => subnet, :name => "a" + FactoryGirl.create(:host).name, :domain => domain
    assert_equal subnet.network, interface.network
    assert_equal subnet.vlanid, interface.vlanid
  end

  test "should reject subnet with mismatched taxonomy in host" do
    taxonomy_to_test = [:organization, :location]

    taxonomy_to_test.each do |taxonomy|
      tax_object1 = FactoryGirl.build(taxonomy)
      tax_object2 = FactoryGirl.build(taxonomy)
      subnet = subnets(:one)
      host = FactoryGirl.build(:host)

      subnet_list = subnet.send("#{taxonomy.to_s.pluralize}")
      subnet_list << tax_object1
      host.send("#{taxonomy}=",tax_object2)

      i = Nic::Base.new :mac => "cabbccddeeff", :host => host
      i.subnet = subnet

      refute i.valid?
    end
  end

  test "should ignore subnet with mismatched taxonomy in host when settings disabled" do
    disable_taxonomies do
      orgs = FactoryGirl.build_pair(:organization)
      locs = FactoryGirl.build_pair(:location)
      subn = FactoryGirl.build(:subnet, :locations => [locs.first], :organizations => [orgs.first])
      host = FactoryGirl.build(:host, :location => locs.last, :organization => orgs.last)
      nic = Nic::Base.new :mac => "cabbccddeeff", :host => host
      nic.subnet = subn
      assert_valid nic
    end
  end

  test "should accept subnets with aligned location and organization in host" do
    location1 = FactoryGirl.build(:location)
    organization1 = FactoryGirl.build(:organization)

    subnet = subnets(:one)
    host = FactoryGirl.build(:host)

    subnet.locations << location1
    subnet.organizations << organization1
    host.location = location1
    host.organization = organization1

    i = Nic::Base.new :mac => "cabbccddeeff", :host => host
    i.subnet = subnet

    assert i.valid?
  end

  test "Nic::Managed#hostname should return blank for blank hostnames" do
    i = Nic::Managed.new :mac => "babbccddeeff00112233445566778899aabbccdd", :host => FactoryGirl.create(:host), :subnet => subnets(:one), :domain => subnets(:one).domains.first, :name => ""
    assert i.name.blank?
    assert i.domain.present?
    assert i.hostname.blank?
  end

  test "Mac address uniqueness validation is skipped for virtual NICs and unmanaged hosts" do
    host = FactoryGirl.create(:host, :managed)
    Nic::Base.create! :mac => "cabbccddeeff", :host => host # physical
    virtual = Nic::Base.new :mac => "cabbccddeeff", :host => host, :virtual => true
    assert virtual.valid?
    assert virtual.save
    another_physical = Nic::Base.new :mac => "cabbccddeeff", :host => host
    refute another_physical.save
    another_physical_on_unmanaged = Nic::Base.new :mac => "cabbccddeeff", :host => FactoryGirl.create(:host)
    assert another_physical_on_unmanaged.save
  end

  test "VLAN requires identifier" do
    nic = FactoryGirl.build(:nic_managed, :virtual => true, :attached_to => 'eth0', :tag => 5, :managed => true, :identifier => '')
    refute nic.valid?
    assert_includes nic.errors.keys, :identifier
  end

  test "Alias requires identifier" do
    nic = FactoryGirl.build(:nic_managed, :virtual => true, :attached_to => 'eth0', :managed => true, :identifier => '')
    refute nic.valid?
    assert_includes nic.errors.keys, :identifier
  end

  test "#alias? detects alias based on virtual and identifier attributes" do
    nic = FactoryGirl.build(:nic_managed, :virtual => true, :attached_to => 'eth0', :managed => true, :identifier => 'eth0')
    refute nic.alias?

    nic.identifier = 'eth0:0'
    assert nic.alias?

    nic.virtual = false
    refute nic.alias?
  end

  test "Alias subnet can only use static boot mode if it's managed" do
    nic = FactoryGirl.build(:nic_managed, :virtual => true, :attached_to => 'eth0', :managed => true, :identifier => 'eth0:0')
    nic.host = FactoryGirl.build(:host)
    nic.subnet = FactoryGirl.build(:subnet, :boot_mode => Subnet::BOOT_MODES[:dhcp])
    refute nic.valid?
    assert_includes nic.errors.keys, :subnet_id

    nic.subnet.boot_mode = Subnet::BOOT_MODES[:static]
    nic.valid?
    refute_includes nic.errors.keys, :subnet_id

    nic.managed = false
    nic.subnet.boot_mode = Subnet::BOOT_MODES[:dhcp]
    nic.valid?
    refute_includes nic.errors.keys, :subnet_id
  end

  test "BMC does not require identifier" do
    nic = FactoryGirl.build(:nic_bmc, :managed => true, :identifier => '')
    nic.valid?
    refute_includes nic.errors.keys, :identifier
  end

  test "Bond requires identifier if managed" do
    nic = FactoryGirl.build(:nic_bond, :attached_devices => 'eth0,eth1', :managed => true, :identifier => 'bond0')
    nic.valid?
    refute_includes nic.errors.keys, :identifier
  end

  test "Bond does not require identifier if not managed" do
    nic = FactoryGirl.build(:nic_bond, :attached_devices => 'eth0,eth1', :managed => false, :identifier => '')
    nic.valid?
    refute_includes nic.errors.keys, :identifier
  end

  context 'physical?' do
    test 'returns true for a physical interface' do
      nic = FactoryGirl.build(:nic_managed, :virtual => false)
      assert nic.physical?
    end

    test 'returns false for a virtual interface' do
      nic = FactoryGirl.build(:nic_managed, :virtual => true)
      refute nic.physical?
    end
  end

  context 'BMC' do
    setup do
      disable_orchestration
      @subnet    = FactoryGirl.create(:subnet, :dhcp)
      @domain    = FactoryGirl.create(:domain)
      @interface = FactoryGirl.create(:nic_bmc, :ip => @subnet.unused_ip,
                                      :host => FactoryGirl.create(:host),
                                      :subnet => @subnet, :domain => @domain, :name => 'bmc')
    end

    test 'Nic::BMC should have hostname containing name and domain name' do
      assert_equal @interface.hostname, "#{@interface.shortname}.#{@domain.name}"
    end

    test 'Nic::BMC should have hostname containing name when domain nil' do
      @interface.domain = nil
      assert_equal @interface.name, @interface.hostname
    end

    test '.proxy uses any BMC SmartProxy if none is found in subnet' do
      assert @subnet.proxies.select { |proxy| proxy.features.map(&:name).include?('BMC') }
      assert_equal @interface.proxy.url, SmartProxy.with_features('BMC').first.url + '/bmc'
    end

    test '.proxy chooses BMC SmartProxy in Nic::BMC subnet if available' do
      @subnet.dhcp.features << Feature.find_by_name('BMC')
      assert_equal @interface.proxy.url, @subnet.dhcp.url + '/bmc'
    end

    test '.proxy raises exception if BMC SmartProxy cannot be found' do
      SmartProxy.with_features('BMC').map(&:destroy)

      assert_raise Foreman::Exception do
        @interface.proxy
      end
    end

    test "bmc requires MAC address if managed" do
      bmc = FactoryGirl.build(:nic_bmc, :managed => true, :mac => '')
      refute bmc.valid?
      assert_includes bmc.errors.keys, :mac
    end

    test "bmc does not require MAC address if unmanaged" do
      bmc = FactoryGirl.build(:nic_bmc, :managed => false, :mac => '')
      bmc.valid?
      refute_includes bmc.errors.keys, :mac
    end

    context "on managed host" do
      setup do
        @host = FactoryGirl.create(:host, :managed, :ip => '127.0.0.1')
      end

      test "we can't destroy primary interface of managed host" do
        interface = @host.primary_interface
        refute interface.destroy
        assert_includes interface.errors.keys, :primary
      end

      test "we can destroy non primary interface of managed host" do
        interface = FactoryGirl.create(:nic_managed, :primary => false, :host => @host)
        assert interface.destroy
      end

      test "we can destroy primary interface when deleting the host" do
        interface = @host.primary_interface
        refute interface.destroy

        # we must reload the object (interface contains validation errors preventing deletion)
        @host.reload
        assert @host.destroy
      end

      test "we can't destroy provision interface of managed host" do
        interface = @host.provision_interface
        refute interface.destroy
        assert_includes interface.errors.keys, :provision
      end

      test "we can destroy non provision interface of managed host" do
        interface = FactoryGirl.create(:nic_managed, :provision => false, :host => @host)
        assert interface.destroy
      end

      test "we can destroy provision interface when deleting the host" do
        interface = @host.provision_interface
        refute interface.destroy

        # we must reload the object (interface contains validtion errors preventin deletion)
        @host.reload
        assert @host.destroy
      end
    end

    context "on unmanaged host" do
      setup do
        @host = FactoryGirl.create(:host)
      end

      test "we can destroy any interface of unmanaged host" do
        interface = @host.primary_interface
        assert interface.destroy
      end

      test "we can destroy any interface of unmanaged host" do
        interface = @host.provision_interface
        assert interface.destroy
      end

      test "host can have one primary interface at most" do
        # factory already created primary interface
        interface = FactoryGirl.build(:nic_managed, :primary => true, :host => @host)
        refute interface.save
        assert_includes interface.errors.keys, :primary

        interface.primary = false
        interface.name = ''
        assert interface.save
      end

      test "provision flag is set for primary interface automatically" do
        primary = FactoryGirl.build(:nic_managed, :primary => true, :provision => false,
                                    :domain => FactoryGirl.build(:domain))
        host = FactoryGirl.create(:host, :interfaces => [primary])
        assert host.save!
        primary.reload
        assert_equal primary, host.provision_interface
      end
    end
  end

  context "allowed type registration" do
    setup do
      class DefaultTestNic < Nic::Base
      end

      class HumanizedTestNic < Nic::Base
        def self.humanized_name
          "Custom"
        end
      end

      class DisallowedTestNic < Nic::Base
      end

      Nic::Base.register_type(DefaultTestNic)
      Nic::Base.register_type(HumanizedTestNic)
    end

    test "base registers allowed nic types" do
      expected_types = [DefaultTestNic, HumanizedTestNic]
      expected_types.map(&:name).each do |type|
        assert Nic::Base.allowed_types.map(&:name).include? type
      end
    end

    test "type_by_name returns nil for an unknown name" do
      assert_equal nil, Nic::Base.type_by_name("UNKNOWN_NAME")
    end

    test "type_by_name finds the class" do
      assert_equal HumanizedTestNic, Nic::Base.type_by_name("custom")
    end

    test "type_by_name returns nil for classes that aren't allowed" do
      assert_equal nil, Nic::Base.type_by_name("DisallowedTestNic")
    end

    test 'fqdn_changed? should be true if name changes' do
      @nic.stubs(:name_changed?).returns(true)
      @nic.stubs(:domain_id_changed?).returns(false)
      assert @nic.fqdn_changed?
    end

    test 'fqdn_changed? should be true if domain changes' do
      @nic.stubs(:name_changed?).returns(false)
      @nic.stubs(:domain_id_changed?).returns(true)
      assert @nic.fqdn_changed?
    end

    test 'fqdn_changed? should be true if name and domain change' do
      @nic.stubs(:name_changed?).returns(true)
      @nic.stubs(:domain_id_changed?).returns(true)
      assert @nic.fqdn_changed?
    end
  end

  test 'new nic name containing existing domain should set nic domain' do
    domain = FactoryGirl.create(:domain)
    host = FactoryGirl.create(:host)
    nic_name = [host.name, domain.name].join('.')
    interface = FactoryGirl.create(:nic_managed, :host => host, :name => nic_name)
    refute_nil(interface.domain)
    assert_equal(interface.domain, domain)
  end

  test 'new nic with non-existing domain should not set nic domain' do
    host = FactoryGirl.create(:host)
    nic_name = [host.name, 'domain.name'].join('.')
    interface = FactoryGirl.create(:nic_managed, :host => host, :name => nic_name)
    assert_nil(interface.domain)
  end

  test 'update nic domain should update nic name' do
    host = FactoryGirl.create(:host)
    existing_domain = Domain.first
    interface = FactoryGirl.create(:nic_managed, :host => host, :name => 'nick')
    # no domain
    assert_equal(interface.name, 'nick')
    interface.update_attributes(:domain_id => existing_domain.id)
    name_should_be = "nick.#{existing_domain.name}"
    assert_equal(name_should_be, interface.name)
    new_domain = FactoryGirl.create(:domain)
    interface.update_attributes(:domain_id => new_domain.id)
    name_should_change_to = "nick.#{new_domain.name}"
    assert_equal(name_should_change_to, interface.name)
  end
end
