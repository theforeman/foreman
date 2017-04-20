require 'test_helper'

class PuppetCaOrchestrationTest < ActiveSupport::TestCase
  def setup
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
    let(:host) { FactoryGirl.create(:host, :managed, :with_puppet_ca, :build => true) }

    test 'should queue puppetca update' do
      host.build = false
      assert_valid host
      tasks = host.queue.all.map(&:name)
      assert_includes tasks, "Delete PuppetCA autosign entry for #{host}"
      assert_equal 1, tasks.size
    end

    test 'should queue puppetca destroy' do
      host.send(:queue_puppetca_destroy)
      tasks = host.queue.all.map(&:name)
      assert_includes tasks, "Delete PuppetCA autosign entry for #{host}"
      assert_includes tasks, "Delete PuppetCA certificates for #{host}"
      assert_equal 2, tasks.size
    end
  end
end
