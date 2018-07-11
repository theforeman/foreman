require 'test_helper'

class PuppetCaOrchestrationTest < ActiveSupport::TestCase
  def setup
    SmartProxyPool.any_instance.stubs(:vaild_certs => true)
    users(:one).roles << Role.find_by_name('Manager')
    User.current = users(:one)
    disable_orchestration
    SETTINGS[:locations_enabled] = false
    SETTINGS[:organizations_enabled] = false
    Setting[:manage_puppetca] = true
    skip_without_unattended
  end

  def teardown
    SETTINGS[:locations_enabled] = true
    SETTINGS[:organizations_enabled] = true
    User.current = nil
  end

  context 'a host with puppetca orchestration' do
    context 'when entering build mode on creation' do
      let(:host) { FactoryBot.create(:host, :managed, :puppet_ca_proxy_pool => FactoryBot.create(:smart_proxy_pool, :with_puppet), :build => true) }

      test 'should queue puppetca autosigning' do
        assert_valid host
        tasks = host.queue.all.sort.map(&:name)
        assert_equal tasks[0], "Cleanup PuppetCA certificates for #{host}"
        assert_equal tasks[1], "Enable PuppetCA autosigning for #{host}"
        assert_equal 2, tasks.size
      end

      test 'should use the hostname for autosigning on setting' do
        Setting[:use_uuid_for_certificates] = false
        assert_valid host
        assert_equal host.certname, host.hostname
        assert host.send(:initialize_puppetca)
        host.puppetca.expects(:set_autosign).with(host.hostname).returns(true)
        assert host.send(:setAutosign)
      end

      test 'should use a uuid for autosigning on setting' do
        Setting[:use_uuid_for_certificates] = true
        assert_valid host
        assert Foreman.is_uuid?(host.certname)
        assert host.send(:initialize_puppetca)
        host.puppetca.expects(:set_autosign).with(host.certname).returns(true)
        assert host.send(:setAutosign)
      end
    end

    context 'when reentering build mode' do
      let(:host) { FactoryBot.create(:host, :managed, :puppet_ca_proxy_pool => FactoryBot.create(:smart_proxy_pool, :with_puppet), :build => false) }

      setup do
        @host = host
        @host.queue.clear
        @host.build = true
        @host.save!
      end

      test 'should queue puppetca autosigning' do
        tasks = @host.queue.all.sort.map(&:name)
        assert_equal tasks[0], "Disable PuppetCA autosigning for #{host}"
        assert_equal tasks[1], "Cleanup PuppetCA certificates for #{host}"
        assert_equal tasks[2], "Enable PuppetCA autosigning for #{host}"
        assert_equal 3, tasks.size
      end
    end

    context 'when reentering build mode after certname setting was changed' do
      let(:host) { FactoryBot.create(:host, :managed, :with_puppet_ca, :build => false) }

      test 'should reset certname when changing from hostname to uuid' do
        assert_valid host
        host.queue.clear
        Setting[:use_uuid_for_certificates] = true
        host.build = true
        host.save!
        tasks = host.queue.all.sort.map(&:name)
        assert_equal tasks[0], "Disable PuppetCA autosigning for #{host}"
        assert_equal tasks[1], "Cleanup PuppetCA certificates for #{host}"
        assert_equal tasks[2], "Enable PuppetCA autosigning for #{host}"
        assert_equal 3, tasks.size
        # Foreman updates the certname automatically in this case
        assert Foreman.is_uuid?(host.certname)
      end

      test 'should reset certname when changing from uuid to hostname' do
        Setting[:use_uuid_for_certificates] = true
        assert_valid host
        host.queue.clear
        Setting[:use_uuid_for_certificates] = false
        host.build = true
        host.save!
        tasks = host.queue.all.sort.map(&:name)
        assert_equal tasks[0], "Reset PuppetCA certname for #{host}"
        assert_equal tasks[1], "Disable PuppetCA autosigning for #{host}"
        assert_equal tasks[2], "Cleanup PuppetCA certificates for #{host}"
        assert_equal tasks[3], "Enable PuppetCA autosigning for #{host}"
        assert_equal 4, tasks.size
      end
    end

    context 'when host leaves build mode' do
      let(:host) { FactoryBot.create(:host, :managed, :with_puppet_ca, :build => true) }

      setup do
        @host = host
        @host.queue.clear
        @host.build = false
        @host.save!
      end

      test 'should remove autosign entry for host' do
        tasks = @host.queue.all.sort.map(&:name)
        assert_equal tasks[0], "Disable PuppetCA autosigning for #{host}"
        assert_equal 1, tasks.size
      end
    end

    context 'when host is updated' do
      let(:host) { FactoryBot.create(:host, :managed, :with_puppet_ca, :build => false) }

      test 'should not queue anything if build mode is not changed' do
        assert_valid host
        host.queue.clear
        host.comment = "updated"
        host.save!
        assert_equal 0, host.queue.all.size
      end
    end

    context 'when host gets destroyed' do
      let(:host) { FactoryBot.create(:host, :managed, :with_puppet_ca, :build => false) }

      test 'should queue puppetca destroy' do
        assert_valid host
        host.queue.clear
        host.send(:queue_puppetca_destroy)
        tasks = host.queue.all.sort.map(&:name)
        assert_equal tasks[0], "Disable PuppetCA autosigning for #{host}"
        assert_equal tasks[1], "Delete PuppetCA certificates for #{host}"
        assert_equal 2, tasks.size
      end
    end
  end
end
