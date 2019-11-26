require 'test_helper'

class NicTest < ActiveSupport::TestCase
  def setup
    disable_orchestration
    User.current = users :admin

    @nic = FactoryBot.build_stubbed(:nic_managed, :host => FactoryBot.build_stubbed(:host, :managed => true))
  end

  def teardown
    User.current = nil
  end

  test "should create simple interface" do
    i = Nic::Base.create! :mac => "cabbccddeeff", :host => FactoryBot.create(:host)
    assert_equal "Nic::Base", i.class.to_s
  end

  test "type casting should return the correct class" do
    i = Nic::Base.create! :ip => "127.2.3.8", :mac => "babbccddeeff", :host => FactoryBot.create(:host),
                          :type => "Nic::Interface"
    assert_equal "Nic::Interface", i.type
  end

  test "should fail on invalid mac" do
    i = Nic::Base.new :mac => "abccddeeff", :host => FactoryBot.create(:host, :managed)
    assert !i.valid?
    assert i.errors.key?(:mac)
  end

  test "should be valid with 64-bit mac address" do
    i = Nic::Base.new :mac => "babbccddeeff00112233445566778899aabbccdd", :host => FactoryBot.create(:host)
    assert i.valid?
    assert !i.errors.key?(:mac)
  end

  test "should fail on invalid dns name" do
    i = Nic::Managed.new :mac => "dabbccddeeff", :host => FactoryBot.create(:host), :name => "invalid_dns_name"
    assert !i.valid?
    assert i.errors.key?(:name)
  end

  test "should fix mac address" do
    interface = Nic::Base.create! :mac => "cabbccddeeff", :host => FactoryBot.create(:host)
    assert_equal "ca:bb:cc:dd:ee:ff", interface.mac
  end

  test "should fix 64-bit mac address" do
    interface = Nic::Base.create! :mac => "babbccddeeff00112233445566778899aabbccdd", :host => FactoryBot.create(:host)
    assert_equal "ba:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99:aa:bb:cc:dd", interface.mac
  end

  test "should fix ip address if a leading zero is used" do
    interface = Nic::Interface.create! :ip => "123.01.02.03", :mac => "dabbccddeeff", :host => FactoryBot.create(:host)
    assert_equal "123.1.2.3", interface.ip
  end

  test "type can't by updated" do
    interface = FactoryBot.create(:nic_managed, :host => FactoryBot.create(:host))
    interface.type = 'Nic::BMC'
    interface.valid?
    assert_includes interface.errors.keys, :type
  end

  test "managed nic should generate progress report uuid" do
    uuid = '710d4a8f-b1b6-47f5-9ef5-5892a19dabcd'
    Foreman.stubs(:uuid).returns(uuid)
    nic = FactoryBot.build_stubbed(:nic_managed)
    assert_equal uuid, nic.progress_report_id
  end

  test "host with managed nic should delegate progress report creation" do
    uuid = '710d4a8f-b1b6-47f5-9ef5-5892a19dabcd'
    host = FactoryBot.create(:host, :managed)
    host.expects(:progress_report_id).returns(uuid)
    assert_equal uuid, host.primary_interface.progress_report_id
  end

  test "should delegate subnet attributes" do
    subnet = subnets(:two)
    subnet6 = subnets(:seven)
    domain = (subnet.domains.any? ? subnet.domains : subnet.domains << Domain.first).first
    interface = FactoryBot.build_stubbed(:nic_managed,
      :ip => "3.3.4.127",
      :mac => "cabbccddeeff",
      :host => FactoryBot.create(:host),
      :subnet => subnet,
      :subnet6 => subnet6,
      :name => "a" + FactoryBot.create(:host).name,
      :domain => domain)
    assert_equal subnet.network, interface.network
    assert_equal subnet6.network, interface.network6
    assert_equal subnet.vlanid, interface.vlanid
    assert_equal 42, interface.vlanid
    assert_equal 3, subnet.nic_delay
    assert_equal 1496, interface.mtu
    assert_equal subnet.mtu, interface.mtu
  end

  test "should delegate subnet6 attributes if subnet is nil" do
    subnet = nil
    subnet6 = subnets(:seven)
    domain = (subnet6.domains.any? ? subnet6.domains : subnet6.domains << Domain.first).first
    interface = FactoryBot.build_stubbed(:nic_managed,
      :ip => "3.3.4.127",
      :mac => "cabbccddeeff",
      :host => FactoryBot.create(:host),
      :subnet => subnet,
      :subnet6 => subnet6,
      :name => "a" + FactoryBot.create(:host).name,
      :domain => domain)
    assert_equal subnet6.vlanid, interface.vlanid
    assert_equal subnet6.mtu, interface.mtu
    assert_equal subnet6.network, interface.network6
    assert_equal 44, interface.vlanid
    assert_equal 9000, interface.mtu
  end

  test "should reject subnet with mismatched taxonomy in host" do
    taxonomy_to_test = [:organization, :location]

    taxonomy_to_test.each do |taxonomy|
      tax_object1 = FactoryBot.build(taxonomy)
      tax_object2 = FactoryBot.build(taxonomy)
      subnet = subnets(:one)
      subnet6 = subnets(:six)
      host = FactoryBot.build(:host)

      subnet_list = subnet.send(taxonomy.to_s.pluralize.to_s)
      subnet_list << tax_object1

      subnet6_list = subnet6.send(taxonomy.to_s.pluralize.to_s)
      subnet6_list << tax_object1

      host.send("#{taxonomy}=", tax_object2)

      nic = Nic::Base.new :mac => "cabbccddeeff", :host => host
      nic.subnet = subnet
      nic.subnet6 = subnet6

      refute nic.valid?, "Can't be valid with mismatching taxonomy: #{nic.errors.messages}"
      assert_includes nic.errors.keys, :subnet_id
      assert_includes nic.errors.keys, :subnet6_id
    end
  end

  test "should accept subnets with aligned location and organization in host" do
    location1 = FactoryBot.build(:location)
    organization1 = FactoryBot.build(:organization)

    subnet = subnets(:one)
    host = FactoryBot.build(:host)

    subnet.locations << location1
    subnet.organizations << organization1
    host.location = location1
    host.organization = organization1

    i = Nic::Base.new :mac => "cabbccddeeff", :host => host
    i.subnet = subnet

    assert i.valid?
  end

  test "Nic::Managed#hostname should return blank for blank hostnames" do
    i = Nic::Managed.new :mac => "babbccddeeff00112233445566778899aabbccdd", :host => FactoryBot.create(:host), :subnet => subnets(:one), :domain => subnets(:one).domains.first, :name => ""
    assert i.name.blank?
    assert i.domain.present?
    assert i.hostname.blank?
  end

  test "Mac address uniqueness validation is skipped for virtual NICs and unmanaged hosts" do
    host = FactoryBot.create(:host, :managed)
    Nic::Base.create! :mac => "cabbccddeeff", :host => host # physical
    host.reload
    virtual = Nic::Base.new :mac => "cabbccddeeff", :host => host, :virtual => true
    assert virtual.valid?
    assert virtual.save
    another_physical = Nic::Base.new :mac => "cabbccddeeff", :host => host
    refute another_physical.save
    another_physical_on_unmanaged = Nic::Base.new :mac => "cabbccddeeff", :host => FactoryBot.create(:host)
    assert another_physical_on_unmanaged.save
  end

  test "VLAN requires identifier" do
    nic = FactoryBot.build(:nic_managed, :virtual => true, :attached_to => 'eth0', :tag => 5, :managed => true, :identifier => '')
    refute nic.valid?
    assert_includes nic.errors.keys, :identifier
  end

  test "Alias requires identifier" do
    nic = FactoryBot.build(:nic_managed, :virtual => true, :attached_to => 'eth0', :managed => true, :identifier => '')
    refute nic.valid?
    assert_includes nic.errors.keys, :identifier
  end

  test "#alias? detects alias based on virtual and identifier attributes" do
    nic = FactoryBot.build_stubbed(:nic_managed, :virtual => true, :attached_to => 'eth0', :managed => true, :identifier => 'eth0')
    refute nic.alias?

    nic.identifier = 'eth0:0'
    assert nic.alias?

    nic.virtual = false
    refute nic.alias?
  end

  test "Alias subnet can only use static boot mode if it's managed" do
    nic = FactoryBot.build_stubbed(:nic_managed, :virtual => true, :attached_to => 'eth0', :managed => true, :identifier => 'eth0:0')
    nic.host = FactoryBot.build_stubbed(:host)
    nic.subnet = FactoryBot.build_stubbed(:subnet_ipv4, :boot_mode => Subnet::BOOT_MODES[:dhcp])
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
    nic = FactoryBot.build(:nic_bmc, :managed => true, :identifier => '')
    nic.valid?
    refute_includes nic.errors.keys, :identifier
  end

  test "Bond requires identifier if managed" do
    nic = FactoryBot.build(:nic_bond, :attached_devices => 'eth0,eth1', :managed => true, :identifier => 'bond0')
    nic.valid?
    refute_includes nic.errors.keys, :identifier
  end

  test "Bond does not require identifier if not managed" do
    nic = FactoryBot.build(:nic_bond, :attached_devices => 'eth0,eth1', :managed => false, :identifier => '')
    nic.valid?
    refute_includes nic.errors.keys, :identifier
  end

  context 'physical?' do
    test 'returns true for a physical interface' do
      nic = FactoryBot.build_stubbed(:nic_managed, :virtual => false)
      assert nic.physical?
    end

    test 'returns false for a virtual interface' do
      nic = FactoryBot.build_stubbed(:nic_managed, :virtual => true)
      refute nic.physical?
    end
  end

  context 'BMC' do
    setup do
      disable_orchestration
      @subnet    = FactoryBot.create(:subnet_ipv4, :dhcp, :ipam => IPAM::MODES[:db])
      @domain    = FactoryBot.create(:domain)
      @interface = FactoryBot.create(:nic_bmc, :ip => @subnet.unused_ip.suggest_ip,
                                      :host => FactoryBot.create(:host),
                                      :subnet => @subnet, :domain => @domain, :name => 'bmc')
    end

    test 'Nic::BMC should have hostname containing name and domain name' do
      assert_equal @interface.hostname, "#{@interface.shortname}.#{@domain.name}"
    end

    test 'Nic::BMC should have hostname containing name when domain nil' do
      @interface.domain = nil
      assert_equal @interface.name, @interface.hostname
    end

    test '.proxy raises exception if BMC proxy is not set' do
      assert @subnet.proxies.select { |proxy| proxy.features.map(&:name).include?('BMC') }
      assert_raise Foreman::BMCFeatureException do
        @interface.proxy.url
      end
    end

    test '.proxy raises exception if BMC SmartProxy cannot be found' do
      SmartProxy.with_features('BMC').map { |sp| sp.features = [] }

      assert_raise Foreman::Exception do
        @interface.reload.proxy
      end
    end

    test "bmc requires MAC address if managed" do
      bmc = FactoryBot.build(:nic_bmc, :managed => true, :mac => '')
      refute bmc.valid?
      assert_includes bmc.errors.keys, :mac
    end

    test "bmc does not require MAC address if unmanaged" do
      bmc = FactoryBot.build(:nic_bmc, :managed => false, :mac => '')
      bmc.valid?
      refute_includes bmc.errors.keys, :mac
    end

    context "on managed host" do
      setup do
        @host = FactoryBot.create(:host, :managed, :ip => '127.0.0.1')
      end

      test "we can't destroy primary interface of managed host" do
        interface = @host.primary_interface
        refute interface.destroy
        assert_includes interface.errors.keys, :primary
      end

      test "we can destroy non primary interface of managed host" do
        interface = FactoryBot.create(:nic_managed, :primary => false, :host => @host)
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
        interface = FactoryBot.create(:nic_managed, :provision => false, :host => @host)
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
        @host = FactoryBot.create(:host)
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
        interface = FactoryBot.build(:nic_managed, :primary => true, :host => @host)
        refute interface.save
        assert_includes interface.errors.keys, :primary

        interface.primary = false
        interface.name = ''
        assert interface.save
      end

      test "provision flag is set for primary interface automatically" do
        primary = FactoryBot.build(:nic_managed, :primary => true, :provision => false,
                                    :domain => FactoryBot.build(:domain))
        host = FactoryBot.create(:host, :interfaces => [primary])
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
      assert_nil Nic::Base.type_by_name("UNKNOWN_NAME")
    end

    test "type_by_name finds the class" do
      assert_equal HumanizedTestNic, Nic::Base.type_by_name("custom")
    end

    test "type_by_name returns nil for classes that aren't allowed" do
      assert_nil Nic::Base.type_by_name("DisallowedTestNic")
    end

    test 'saved_change_to_fqdn? should be true if name changes' do
      @nic.stubs(:saved_change_to_name?).returns(true)
      @nic.stubs(:saved_change_to_domain_id?).returns(false)
      assert @nic.saved_change_to_fqdn?
    end

    test 'saved_change_to_fqdn? should be true if domain changes' do
      @nic.stubs(:saved_change_to_name?).returns(false)
      @nic.stubs(:saved_change_to_domain_id?).returns(true)
      assert @nic.saved_change_to_fqdn?
    end

    test 'saved_change_to_fqdn? should be true if name and domain change' do
      @nic.stubs(:saved_change_to_name?).returns(true)
      @nic.stubs(:saved_change_to_domain_id?).returns(true)
      assert @nic.saved_change_to_fqdn?
    end
  end

  test 'new nic name containing existing domain should set nic domain' do
    domain = FactoryBot.create(:domain)
    host = FactoryBot.create(:host)
    nic_name = [host.name, domain.name].join('.')
    interface = FactoryBot.create(:nic_managed, :host => host, :name => nic_name)
    refute_nil(interface.domain)
    assert_equal(interface.domain, domain)
  end

  test 'new nic name containing existing subdomain should set nic domain correctly' do
    nic_name = 'hostname.sub.bigdomain'
    interface = FactoryBot.build_stubbed(:nic_managed, :name => nic_name)
    subdomain = FactoryBot.create(:domain, :name => 'sub.bigdomain')
    interface.send(:normalize_name)
    assert_equal subdomain, interface.domain
  end

  test 'new nic name containing non-existing subdomain should not set nic domain' do
    nic_name = 'hostname.undefined-subdomain.bigdomain'
    FactoryBot.create(:domain, :name => 'bigdomain')
    interface = FactoryBot.build_stubbed(:nic_managed, :name => nic_name)
    interface.send(:normalize_name)
    refute interface.domain
  end

  test 'new nic with non-existing domain should not set nic domain' do
    host = FactoryBot.create(:host)
    nic_name = [host.name, 'domain.name'].join('.')
    interface = FactoryBot.create(:nic_managed, :host => host, :name => nic_name)
    assert_nil(interface.domain)
  end

  test 'update nic domain should update nic name' do
    host = FactoryBot.create(:host)
    existing_domain = Domain.first
    interface = FactoryBot.create(:nic_managed, :host => host, :name => 'nick')
    # no domain
    assert_equal(interface.name, 'nick')
    interface.update(:domain_id => existing_domain.id)
    name_should_be = "nick.#{existing_domain.name}"
    assert_equal(name_should_be, interface.name)
    new_domain = FactoryBot.create(:domain)
    interface.update(:domain_id => new_domain.id)
    name_should_change_to = "nick.#{new_domain.name}"
    assert_equal(name_should_change_to, interface.name)
  end

  test 'nic MTU fact should override subnet MTU' do
    domain = FactoryBot.create(:domain)
    subnet = FactoryBot.create(:subnet_ipv4, :domains => [domain], :mtu => 9000)
    interface = FactoryBot.build(:nic_managed, :name => 'nick', :subnet => subnet)
    interface.attrs['mtu'] = 1500
    assert_equal 1500, interface.mtu
  end

  test 'nic with both subnet and subnet6 should be valid if VLAN ID is consistent between subnets' do
    host = FactoryBot.create(:host)
    domain = FactoryBot.create(:domain)
    subnet = FactoryBot.create(:subnet_ipv4, :domains => [domain], :vlanid => 14)
    subnet6 = FactoryBot.create(:subnet_ipv6, :domains => [domain], :vlanid => 14)
    interface = FactoryBot.create(:nic_managed, :host => host, :name => 'nick', :subnet => subnet, :subnet6 => subnet6)
    assert_valid interface
  end

  test 'nic with both subnet and subnet6 should not be valid if VLAN ID mismatch between subnets' do
    host = FactoryBot.create(:host)
    domain = FactoryBot.create(:domain)
    subnet = FactoryBot.create(:subnet_ipv4, :domains => [domain], :vlanid => 3)
    subnet6 = FactoryBot.create(:subnet_ipv6, :domains => [domain], :vlanid => 4)
    interface = FactoryBot.build(:nic_managed, :host => host, :name => 'nick', :subnet => subnet, :subnet6 => subnet6)
    refute_valid interface
    assert_includes interface.errors.keys, :subnet_id

    subnet6 = FactoryBot.create(:subnet_ipv6, :domains => [domain], :vlanid => nil)
    interface = FactoryBot.build(:nic_managed, :host => host, :name => 'nick', :subnet => subnet, :subnet6 => subnet6)
    refute_valid interface
    assert_includes interface.errors.keys, :subnet_id
  end

  test 'nic with both subnet and subnet6 should be valid if MTU is consistent between subnets' do
    host = FactoryBot.create(:host)
    domain = FactoryBot.create(:domain)
    subnet = FactoryBot.create(:subnet_ipv4, :domains => [domain], :mtu => 1496)
    subnet6 = FactoryBot.create(:subnet_ipv6, :domains => [domain], :mtu => 1496)
    interface = FactoryBot.build(:nic_managed, :host => host, :name => 'nick', :subnet => subnet, :subnet6 => subnet6)
    assert_valid interface
  end

  test 'nic with both subnet and subnet6 should not be valid if MTU mismatch between subnets' do
    host = FactoryBot.create(:host)
    domain = FactoryBot.create(:domain)
    subnet = FactoryBot.create(:subnet_ipv4, :domains => [domain], :mtu => 1496)
    subnet6 = FactoryBot.create(:subnet_ipv6, :domains => [domain], :mtu => 1500)
    interface = FactoryBot.build(:nic_managed, :host => host, :name => 'nick', :subnet => subnet, :subnet6 => subnet6)
    refute_valid interface
    assert_includes interface.errors.keys, :subnet_id
  end

  test 'test nic audit records should consider taxonomies from associated host' do
    org = taxonomies(:organization1)
    sample_host = FactoryBot.create(:host, :with_auditing, :organization_id => org.id)
    foo_nic = FactoryBot.create(:nic_managed, :with_auditing, :host => sample_host, :name => 'nic-foobar')

    recent_audit = Audit.where(auditable_id: foo_nic.id).last
    assert recent_audit, "No audit record for nic"
    assert_equal 'create', recent_audit.action
    assert_includes recent_audit.organization_ids, sample_host.organization_id
    nic_record = sample_host.associated_audits.where(auditable_id: foo_nic.id)
    assert nic_record, "No associated audit record for nic"
  end
end
