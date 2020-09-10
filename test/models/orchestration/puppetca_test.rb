require 'test_helper'

class PuppetCaOrchestrationTest < ActiveSupport::TestCase
  def setup
    users(:one).roles << Role.find_by_name('Manager')
    User.current = users(:one)
    disable_orchestration
    Setting[:manage_puppetca] = true
    skip_without_unattended
  end

  def teardown
    User.current = nil
  end

  context 'a host with puppetca orchestration' do
    context 'when entering build mode on creation' do
      let(:host) { FactoryBot.create(:host, :managed, :with_puppet_ca, :build => true) }

      test 'should queue puppetca autosigning' do
        assert_valid host
        tasks = host.post_queue.all.sort.map(&:name)
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
      let(:host) { FactoryBot.create(:host, :managed, :with_puppet_ca, :build => false) }

      setup do
        @host = host
        @host.post_queue.clear
        @host.build = true
        @host.save!
      end

      test 'should queue puppetca autosigning' do
        tasks = @host.post_queue.all.sort.map(&:name)
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
        host.post_queue.clear
        Setting[:use_uuid_for_certificates] = true
        host.build = true
        host.save!
        tasks = host.post_queue.all.sort.map(&:name)
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
        host.post_queue.clear
        Setting[:use_uuid_for_certificates] = false
        host.build = true
        host.save!
        tasks = host.post_queue.all.sort.map(&:name)
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
        @host.post_queue.clear
        @host.build = false
        @host.save!
      end

      test 'should remove autosign entry for host' do
        tasks = @host.post_queue.all.sort.map(&:name)
        assert_equal tasks[0], "Disable PuppetCA autosigning for #{host}"
        assert_equal 1, tasks.size
      end
    end

    context 'when host is updated' do
      let(:host) { FactoryBot.create(:host, :managed, :with_puppet_ca, :build => false) }

      test 'should not queue anything if build mode is not changed' do
        assert_valid host
        host.post_queue.clear
        host.comment = "updated"
        host.save!
        assert_equal 0, host.post_queue.all.size
      end
    end

    context 'when host gets destroyed' do
      let(:host) { FactoryBot.create(:host, :managed, :with_puppet_ca, :build => false) }

      test 'should queue puppetca destroy' do
        assert_valid host
        host.post_queue.clear
        host.send(:queue_puppetca_destroy)
        tasks = host.post_queue.all.sort.map(&:name)
        assert_equal tasks[0], "Disable PuppetCA autosigning for #{host}"
        assert_equal tasks[1], "Delete PuppetCA certificates for #{host}"
        assert_equal 2, tasks.size
      end
    end

    context 'handles smart proxy responses correctly' do
      let(:host) { FactoryBot.create(:host, :managed, :with_puppet_ca, :build => true) }

      setup do
        @host = host
        @host.send(:initialize_puppetca)
      end

      test 'when it uses basic autosigning' do
        @host.puppetca.stubs(:set_autosign).with(@host.certname).returns(true)
        assert @host.send(:setAutosign)
        assert_nil @host.puppetca_token
      end

      test 'when autosigning fails' do
        @host.puppetca.stubs(:set_autosign).with(@host.certname).returns(false)
        refute @host.send(:setAutosign)
        assert_nil @host.puppetca_token
      end

      test 'when using token based autosigning' do
        spresponse = { 'generated_token' => 'foo42' }
        @host.puppetca.stubs(:set_autosign).with(@host.certname).returns(spresponse)
        assert @host.send(:setAutosign)
        assert_valid @host.puppetca_token
        assert_equal @host.puppetca_token.value, 'foo42'
      end

      test 'when it gets an invalid hash response' do
        spresponse = { 'not_a_token' => '' }
        @host.puppetca.stubs(:set_autosign).with(@host.certname).returns(spresponse)
        refute @host.send(:setAutosign)
        assert_nil @host.puppetca_token
      end

      test 'when it gets an invalid nil response' do
        @host.puppetca.stubs(:set_autosign).with(@host.certname).returns(nil)
        refute @host.send(:setAutosign)
        assert_nil @host.puppetca_token
      end
    end
  end
end
