require 'test_helper'

class DnsOrchestrationTest < ActiveSupport::TestCase
  def setup
    disable_orchestration
  end

  context 'host without dns' do
    setup do
      @host = FactoryBot.build(:host)
    end

    test 'host should not have dns' do
      assert_valid @host
      refute @host.dns?
      refute @host.dns6?
      refute @host.reverse_dns?
      refute @host.reverse_dns6?
      assert_nil @host.dns_record(:a)
      assert_nil @host.dns_record(:aaaa)
      assert_nil @host.dns_record(:ptr4)
      assert_nil @host.dns_record(:ptr6)
    end

    test 'unmanaged should not call methods after managed?' do
      Nic::Managed.any_instance.expects(:ip_available?).never
      assert_valid @host
      refute @host.dns?
      refute @host.reverse_dns?
      refute @host.dns6?
      refute @host.reverse_dns6?
    end

    test 'should skip dns rebuild' do
      Nic::Managed.any_instance.expects(:del_dns_record).with(:a).never
      Nic::Managed.any_instance.expects(:del_dns_record).with(:aaaa).never
      Nic::Managed.any_instance.expects(:del_dns_record).with(:ptr4).never
      Nic::Managed.any_instance.expects(:del_dns_record).with(:ptr6).never
      Nic::Managed.any_instance.expects(:recreate_dns_record).with(:a).never
      Nic::Managed.any_instance.expects(:recreate_dns_record).with(:aaaa).never
      Nic::Managed.any_instance.expects(:recreate_dns_record).with(:ptr4).never
      Nic::Managed.any_instance.expects(:recreate_dns_record).with(:ptr6).never
      @host.save!
      assert @host.interfaces.first.rebuild_dns
    end
  end

  context 'host with ipv4 dns' do
    setup do
      @host = FactoryBot.build(:host, :managed, :with_dns_orchestration)
    end

    test 'host should have dns' do
      assert_valid @host
      assert @host.dns?
      refute @host.dns6?
      assert @host.reverse_dns?
      refute @host.reverse_dns6?
      assert_not_nil @host.dns_record(:a)
      assert_not_nil @host.dns_record(:ptr4)
      assert_nil @host.dns_record(:aaaa)
      assert_nil @host.dns_record(:ptr6)
    end

    test 'host should have dns but not ptr' do
      @host.subnet = nil
      assert_valid @host
      assert @host.dns?
      assert !@host.reverse_dns?
      assert_not_nil @host.dns_record(:a)
      assert_nil @host.dns_record(:ptr4)
    end

    test 'host should not have dns but should have ptr' do
      @host.domain.dns = nil
      assert_valid @host
      assert !@host.dns?
      assert @host.reverse_dns?
      assert_nil @host.dns_record(:a)
      assert_not_nil @host.dns_record(:ptr4)
    end

    test 'dns record should be nil for invalid ip' do
      @host.interfaces = [FactoryBot.build_stubbed(:nic_primary_and_provision, :ip => "aaaaaaa")]
      assert_nil @host.dns_record(:a)
      assert_nil @host.dns_record(:ptr4)
    end

    test 'should rebuild dns' do
      Nic::Managed.any_instance.expects(:del_dns_record).with(:a)
      Nic::Managed.any_instance.expects(:del_dns_record).with(:aaaa).never
      Nic::Managed.any_instance.expects(:del_dns_record).with(:ptr4)
      Nic::Managed.any_instance.expects(:del_dns_record).with(:ptr6).never
      Nic::Managed.any_instance.expects(:recreate_dns_record).with(:a).returns(true)
      Nic::Managed.any_instance.expects(:recreate_dns_record).with(:aaaa).never
      Nic::Managed.any_instance.expects(:recreate_dns_record).with(:ptr4).returns(true)
      Nic::Managed.any_instance.expects(:recreate_dns_record).with(:ptr6).never
      @host.save!
      assert @host.interfaces.first.rebuild_dns
    end

    test 'dns rebuild should fail' do
      Nic::Managed.any_instance.expects(:del_dns_record).with(:a)
      Nic::Managed.any_instance.expects(:del_dns_record).with(:ptr4)
      Nic::Managed.any_instance.expects(:recreate_dns_record).with(:a).returns(true)
      Nic::Managed.any_instance.expects(:recreate_dns_record).with(:ptr4).returns(false)
      @host.save!
      refute @host.interfaces.first.rebuild_dns
    end

    test 'dns rebuild should fail with exception' do
      Nic::Managed.any_instance.expects(:del_dns_record).with(:a)
      Nic::Managed.any_instance.expects(:del_dns_record).with(:ptr4)
      Nic::Managed.any_instance.expects(:recreate_dns_record).with(:a).returns(true)
      Nic::Managed.any_instance.stubs(:recreate_dns_record).with(:ptr4).raises(StandardError, 'DNS test fail')
      @host.save!
      refute @host.interfaces.first.rebuild_dns
    end

    test 'should queue dns create' do
      assert_valid @host
      tasks = @host.queue.all.map(&:name)
      assert_includes tasks, "Create IPv4 DNS record for #{@host.provision_interface}"
      assert_includes tasks, "Create Reverse IPv4 DNS record for #{@host.provision_interface}"
      assert_equal 2, tasks.size
    end

    test 'IP address change should queue dns update' do
      @host.save!
      @host.queue.clear
      @host.ip = IPAddr.new(IPAddr.new(@host.ip).to_i + 1, Socket::AF_INET).to_s
      assert_valid @host
      tasks = @host.queue.all.map(&:name)
      assert_includes tasks, "Remove IPv4 DNS record for #{@host.provision_interface}"
      assert_includes tasks, "Remove Reverse IPv4 DNS record for #{@host.provision_interface}"
      assert_includes tasks, "Create IPv4 DNS record for #{@host.provision_interface}"
      assert_includes tasks, "Create Reverse IPv4 DNS record for #{@host.provision_interface}"
      assert_equal 4, tasks.size
    end

    test 'name change should queue dns update' do
      @host.save!
      @host.queue.clear
      original_name = @host.primary_interface.name
      @host.primary_interface.name = 'updated-' + @host.primary_interface.name
      assert_valid @host
      tasks = @host.queue.all.map(&:name)
      assert_includes tasks, "Remove IPv4 DNS record for #{original_name}"
      assert_includes tasks, "Remove Reverse IPv4 DNS record for #{original_name}"
      assert_includes tasks, "Create IPv4 DNS record for #{@host.provision_interface}"
      assert_includes tasks, "Create Reverse IPv4 DNS record for #{@host.provision_interface}"
      assert_equal 4, tasks.size
    end

    test 'name deletion should queue dns update on a secondary interface' do
      secondary = FactoryBot.create(:nic_managed, :primary => false, :ip => "1.2.3.4", :host => @host, :domain => @host.domain, :name => 'secondary')
      @host.interfaces << secondary
      @host.save!
      @host.queue.clear
      original_name = secondary.name
      secondary.name = ''
      assert_valid @host
      tasks = @host.queue.all.map(&:name)
      assert_equal 2, @host.interfaces.count
      assert_includes tasks, "Remove IPv4 DNS record for #{original_name}"
      assert_equal 1, tasks.size
    end

    test 'should not queue dns update on blank IPv6 change' do
      @host.ip6 = nil
      @host.save!
      @host.queue.clear
      @host.ip6 = ''
      assert_valid @host
      assert_empty @host.queue.all
    end

    test 'should queue dns destroy' do
      assert_valid @host
      @host.queue.clear
      @host.provision_interface.send(:queue_dns_destroy)
      tasks = @host.queue.all.map(&:name)
      assert_includes tasks, "Remove IPv4 DNS record for #{@host.provision_interface}"
      assert_includes tasks, "Remove Reverse IPv4 DNS record for #{@host.provision_interface}"
      assert_equal 2, tasks.size
    end

    context 'overwrite enabled' do
      setup do
        record = OpenStruct.new(:conflicting? => true)
        @host.primary_interface.expects(:get_dns_record).at_least_once.returns(record)
        @host.overwrite = true
      end

      test 'should queue dns create' do
        assert_valid @host
        tasks = @host.queue.all.map(&:name)
        assert_includes tasks, "Create IPv4 DNS record for #{@host.provision_interface}"
        assert_includes tasks, "Create Reverse IPv4 DNS record for #{@host.provision_interface}"
        assert_includes tasks, "Remove conflicting IPv4 DNS record for #{@host.provision_interface}"
        assert_includes tasks, "Remove conflicting Reverse IPv4 DNS record for #{@host.provision_interface}"
        assert_equal 4, tasks.size
      end
    end

    context 'dns not feasible' do
      test 'should not fail dns rebuild' do
        Nic::Managed.any_instance.stubs(:dns_feasible?).returns(false)
        Nic::Managed.any_instance.expects(:recreate_dns_record).never
        @host.save!
        assert @host.interfaces.first.rebuild_dns
      end
    end
  end

  context 'host with ipv6 dns' do
    setup do
      @host = FactoryBot.build(:host, :managed, :with_ipv6_dns_orchestration)
    end

    test 'host should have dns' do
      assert_valid @host
      refute @host.dns?
      assert @host.dns6?
      refute @host.reverse_dns?
      assert @host.reverse_dns6?
      assert_nil @host.dns_record(:a)
      assert_nil @host.dns_record(:ptr4)
      assert_not_nil @host.dns_record(:aaaa)
      assert_not_nil @host.dns_record(:ptr6)
    end

    test 'should rebuild dns' do
      Nic::Managed.any_instance.expects(:del_dns_record).with(:a).never
      Nic::Managed.any_instance.expects(:del_dns_record).with(:aaaa)
      Nic::Managed.any_instance.expects(:del_dns_record).with(:ptr4).never
      Nic::Managed.any_instance.expects(:del_dns_record).with(:ptr6)
      Nic::Managed.any_instance.expects(:recreate_dns_record).with(:a).never
      Nic::Managed.any_instance.expects(:recreate_dns_record).with(:aaaa).returns(true)
      Nic::Managed.any_instance.expects(:recreate_dns_record).with(:ptr4).never
      Nic::Managed.any_instance.expects(:recreate_dns_record).with(:ptr6).returns(true)
      @host.save!
      assert @host.interfaces.first.rebuild_dns
    end

    test 'should queue dns create' do
      assert_valid @host
      tasks = @host.queue.all.map(&:name)
      assert_includes tasks, "Create IPv6 DNS record for #{@host.provision_interface}"
      assert_includes tasks, "Create Reverse IPv6 DNS record for #{@host.provision_interface}"
      assert_equal 2, tasks.size
    end

    test 'should queue dns update' do
      @host.save!
      @host.queue.clear
      @host.ip6 = IPAddr.new(IPAddr.new(@host.ip6).to_i + 1, Socket::AF_INET6).to_s
      assert_valid @host
      tasks = @host.queue.all.map(&:name)
      assert_includes tasks, "Remove IPv6 DNS record for #{@host.provision_interface}"
      assert_includes tasks, "Remove Reverse IPv6 DNS record for #{@host.provision_interface}"
      assert_includes tasks, "Create IPv6 DNS record for #{@host.provision_interface}"
      assert_includes tasks, "Create Reverse IPv6 DNS record for #{@host.provision_interface}"
      assert_equal 4, tasks.size
    end

    test 'should queue dns destroy' do
      assert_valid @host
      @host.queue.clear
      @host.provision_interface.send(:queue_dns_destroy)
      tasks = @host.queue.all.map(&:name)
      assert_includes tasks, "Remove IPv6 DNS record for #{@host.provision_interface}"
      assert_includes tasks, "Remove Reverse IPv6 DNS record for #{@host.provision_interface}"
      assert_equal 2, tasks.size
    end

    context 'overwrite enabled' do
      setup do
        record = OpenStruct.new(:conflicting? => true)
        @host.primary_interface.expects(:get_dns_record).at_least_once.returns(record)
        @host.overwrite = true
      end

      test 'should queue dns create' do
        assert_valid @host
        tasks = @host.queue.all.map(&:name)
        assert_includes tasks, "Create IPv6 DNS record for #{@host.provision_interface}"
        assert_includes tasks, "Create Reverse IPv6 DNS record for #{@host.provision_interface}"
        assert_includes tasks, "Remove conflicting IPv6 DNS record for #{@host.provision_interface}"
        assert_includes tasks, "Remove conflicting Reverse IPv6 DNS record for #{@host.provision_interface}"
        assert_equal 4, tasks.size
      end
    end
  end

  context 'host with dual stack dns' do
    setup do
      @host = FactoryBot.build(:host, :managed, :with_dual_stack_dns_orchestration)
    end

    test 'host should have dns' do
      assert_valid @host
      assert @host.dns?
      assert @host.dns6?
      assert @host.reverse_dns?
      assert @host.reverse_dns6?
      assert_not_nil @host.dns_record(:a)
      assert_not_nil @host.dns_record(:ptr4)
      assert_not_nil @host.dns_record(:aaaa)
      assert_not_nil @host.dns_record(:ptr6)
    end

    test 'should rebuild dns' do
      Nic::Managed.any_instance.expects(:del_dns_record).with(:a)
      Nic::Managed.any_instance.expects(:del_dns_record).with(:aaaa)
      Nic::Managed.any_instance.expects(:del_dns_record).with(:ptr4)
      Nic::Managed.any_instance.expects(:del_dns_record).with(:ptr6)
      Nic::Managed.any_instance.expects(:recreate_dns_record).with(:a).returns(true)
      Nic::Managed.any_instance.expects(:recreate_dns_record).with(:aaaa).returns(true)
      Nic::Managed.any_instance.expects(:recreate_dns_record).with(:ptr4).returns(true)
      Nic::Managed.any_instance.expects(:recreate_dns_record).with(:ptr6).returns(true)
      @host.save!
      assert @host.interfaces.first.rebuild_dns
    end

    test 'should queue dns create' do
      assert_valid @host
      tasks = @host.queue.all.map(&:name)
      assert_includes tasks, "Create IPv4 DNS record for #{@host.provision_interface}"
      assert_includes tasks, "Create IPv6 DNS record for #{@host.provision_interface}"
      assert_includes tasks, "Create Reverse IPv4 DNS record for #{@host.provision_interface}"
      assert_includes tasks, "Create Reverse IPv6 DNS record for #{@host.provision_interface}"
      assert_equal 4, tasks.size
    end

    test 'should queue dns update' do
      @host.save!
      @host.queue.clear
      @host.ip = IPAddr.new(IPAddr.new(@host.ip).to_i + 1, Socket::AF_INET).to_s
      assert_valid @host
      tasks = @host.queue.all.map(&:name)
      assert_includes tasks, "Remove IPv4 DNS record for #{@host.provision_interface}"
      assert_includes tasks, "Remove IPv6 DNS record for #{@host.provision_interface}"
      assert_includes tasks, "Remove Reverse IPv4 DNS record for #{@host.provision_interface}"
      assert_includes tasks, "Remove Reverse IPv6 DNS record for #{@host.provision_interface}"
      assert_includes tasks, "Create IPv4 DNS record for #{@host.provision_interface}"
      assert_includes tasks, "Create IPv6 DNS record for #{@host.provision_interface}"
      assert_includes tasks, "Create Reverse IPv6 DNS record for #{@host.provision_interface}"
      assert_includes tasks, "Create Reverse IPv4 DNS record for #{@host.provision_interface}"
      assert_equal 8, tasks.size
    end

    test 'should queue dns destroy' do
      assert_valid @host
      @host.queue.clear
      @host.provision_interface.send(:queue_dns_destroy)
      tasks = @host.queue.all.map(&:name)
      assert_includes tasks, "Remove IPv6 DNS record for #{@host.provision_interface}"
      assert_includes tasks, "Remove IPv4 DNS record for #{@host.provision_interface}"
      assert_includes tasks, "Remove Reverse IPv6 DNS record for #{@host.provision_interface}"
      assert_includes tasks, "Remove Reverse IPv4 DNS record for #{@host.provision_interface}"
      assert_equal 4, tasks.size
    end

    context 'overwrite enabled' do
      setup do
        record = OpenStruct.new(:conflicting? => true)
        @host.primary_interface.expects(:get_dns_record).at_least_once.returns(record)
        @host.overwrite = true
      end

      test 'should queue dns create' do
        assert_valid @host
        tasks = @host.queue.all.map(&:name)
        assert_includes tasks, "Create IPv4 DNS record for #{@host.provision_interface}"
        assert_includes tasks, "Create IPv6 DNS record for #{@host.provision_interface}"
        assert_includes tasks, "Create Reverse IPv4 DNS record for #{@host.provision_interface}"
        assert_includes tasks, "Create Reverse IPv6 DNS record for #{@host.provision_interface}"
        assert_includes tasks, "Remove conflicting IPv4 DNS record for #{@host.provision_interface}"
        assert_includes tasks, "Remove conflicting IPv6 DNS record for #{@host.provision_interface}"
        assert_includes tasks, "Remove conflicting Reverse IPv4 DNS record for #{@host.provision_interface}"
        assert_includes tasks, "Remove conflicting Reverse IPv6 DNS record for #{@host.provision_interface}"
        assert_equal 8, tasks.size
      end
    end
  end

  context 'unmanaged host with ipv4 dns' do
    setup do
      @host = FactoryBot.create(:host, :with_dns_orchestration)
    end

    test 'bmc should have valid dns records' do
      bmc = FactoryBot.create(:nic_bmc, :host => @host,
                             :domain => domains(:mydomain),
                             :subnet => subnets(:five),
                             :name => @host.shortname,
                             :ip => '10.0.0.3')
      assert bmc.dns?
      assert bmc.reverse_dns?
      assert_equal "#{bmc.shortname}.#{bmc.domain.name}/#{bmc.ip}", bmc.dns_record(:a).to_s
      assert_equal "#{bmc.ip}/#{bmc.shortname}.#{bmc.domain.name}", bmc.dns_record(:ptr4).to_s
    end

    test 'should error timeout error properly with nameservers' do
      Net::DNS::ARecord.any_instance.stubs(:conflicting?).returns(true)
      Net::DNS::ARecord.any_instance.stubs(:conflicts).raises(Net::Error)
      @host.primary_interface.domain.stubs(:nameservers).returns(["1.2.3.4"])
      @host.primary_interface.send(:dns_conflict_detected?)
      assert_match /^Error connecting .* DNS servers/, @host.errors[:base].first
    end

    test 'should error timeout error properly without nameservers' do
      Net::DNS::ARecord.any_instance.stubs(:conflicting?).returns(true)
      Net::DNS::ARecord.any_instance.stubs(:conflicts).raises(Net::Error)
      @host.primary_interface.domain.stubs(:nameservers).returns([])
      @host.primary_interface.send(:dns_conflict_detected?)
      assert_match /^Error connecting to system DNS/, @host.errors[:base].first
    end
  end
end
