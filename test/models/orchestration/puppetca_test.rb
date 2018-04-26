require 'test_helper'

class PuppetCaOrchestrationTest < ActiveSupport::TestCase
  def setup
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
    let(:host) { FactoryBot.create(:host, :managed, :with_puppet_ca, :build => true) }

    test 'should queue puppetca_token creation' do
      assert_valid host
      tasks = host.post_queue.all.map(&:name)
      assert_includes tasks, "Enable PuppetCA autosign for #{host}"
      assert_equal 1, tasks.size
    end

    test 'should queue puppetca update' do
      host = FactoryBot.create(:host, :managed, :with_puppet_ca)
      host.build = true
      assert_valid host
      host.send(:queue_puppetca_update)
      tasks = host.post_queue.all.map(&:name)
      assert_includes tasks, "Disable PuppetCA autosign for #{host}"
      assert_includes tasks, "Enable PuppetCA autosign for #{host}"
      assert_equal 2, tasks.size
    end

    test 'should not queue puppetca update when build status not changed' do
      assert_valid host
      host.send(:queue_puppetca_update)
      tasks = host.post_queue.all.map(&:name)
      assert_includes tasks, "Enable PuppetCA autosign for #{host}"
      assert_equal 1, tasks.size
    end

    test 'should queue puppetca destroy' do
      assert_valid host
      host.send(:queue_puppetca_destroy)
      tasks = host.post_queue.all.map(&:name)
      assert_includes tasks, "Enable PuppetCA autosign for #{host}"
      assert_includes tasks, "Delete PuppetCA certificates for #{host}"
      assert_includes tasks, "Disable PuppetCA autosign for #{host}"
      assert_equal 3, tasks.size
    end
  end
end
