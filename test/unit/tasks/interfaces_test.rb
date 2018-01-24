require 'test_helper'
require 'rake'

class InterfacesTest < ActiveSupport::TestCase
  let(:null_store) { ActiveSupport::Cache.lookup_store(:null_store) }

  setup do
    Rake.application.rake_require 'tasks/interfaces'
    Rake::Task.define_task(:environment)
    Rake::Task['interfaces:clean'].reenable

    @cleaner = InterfaceCleaner.new

    InterfaceCleaner.stubs(:new).returns(@cleaner)
  end

  test 'interface:clean prints deleted count' do
    @cleaner.stubs(:deleted_count).returns(10)

    stdout, _stderr = capture_io do
      Rake.application.invoke_task 'interfaces:clean'
    end

    assert_match /cleaned 10 interfaces/, stdout
  end

  test 'interface:clean warns about primary interface' do
    Setting.stubs(:cache).returns(null_store)
    Setting[:ignored_interface_identifiers] = ['ignored*']
    host = FactoryBot.create(:host, interfaces: [FactoryBot.build(:nic_managed, identifier: 'ignored01', primary: true, provision: false)])

    stdout, _stderr = capture_io do
      Rake.application.invoke_task 'interfaces:clean'
    end

    assert_match /cleaned 0 interfaces/, stdout
    encoded_hostname = URI.encode("(#{host.name})")
    assert_match /#{encoded_hostname}/, stdout
    assert_match /ignored interface set as primary/, stdout
  end

  test 'interface:clean warns about provision interface' do
    Setting.stubs(:cache).returns(null_store)
    Setting[:ignored_interface_identifiers] = ['ignored*']
    host = FactoryBot.create(:host, interfaces: [FactoryBot.build(:nic_managed, identifier: 'ignored01', primary: false, provision: true)])

    stdout, _stderr = capture_io do
      Rake.application.invoke_task 'interfaces:clean'
    end

    assert_match /cleaned 0 interfaces/, stdout
    encoded_hostname = URI.encode("(#{host.name})")
    assert_match /#{encoded_hostname}/, stdout
    query = URI.decode(stdout.match(/^.*search=(.*?%29)/)[1]).tr('+', ' ')
    assert_equal host.id, Host.search_for(query).first.id
    assert_match /ignored interface set as provision/, stdout
  end
end
