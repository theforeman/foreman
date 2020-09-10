require 'test_helper'

class InterfaceCleanerTest < ActiveSupport::TestCase
  let(:null_store) { ActiveSupport::Cache.lookup_store(:null_store) }
  let(:cleaner) do
    InterfaceCleaner.new
  end

  test "it cleans excluded interfaces" do
    Setting.stubs(:cache).returns(null_store)
    Setting[:ignored_interface_identifiers] = ['ignored*']

    host = FactoryBot.create(:host, :managed)
    additional_interface = FactoryBot.build(:nic_managed, :without_ipv4)
    additional_interface.identifier = 'ignored01'
    host.interfaces << additional_interface
    host.save!

    assert_difference 'Nic::Base.unscoped.count', -1 do
      cleaner.clean!
    end

    assert_equal 1, cleaner.deleted_count
  end

  test "it warns about primary and provision interfaces" do
    Setting.stubs(:cache).returns(null_store)
    Setting[:ignored_interface_identifiers] = ['ignored*']

    host = FactoryBot.create(:host, :managed)
    host.primary_interface.identifier = 'ignored01'
    host.save!

    assert_difference 'Nic::Base.unscoped.count', 0 do
      cleaner.clean!
    end

    assert_equal 0, cleaner.deleted_count
    assert_equal host.primary_interface.id, cleaner.primary_nics.first
    assert_equal host.provision_interface.id, cleaner.provision_nics.first
    assert_equal host.id, cleaner.primary_hosts.first
    assert_equal host.id, cleaner.provision_hosts.first
  end

  test "it handles underscores" do
    Setting.stubs(:cache).returns(null_store)
    Setting[:ignored_interface_identifiers] = ['test_underscore*']

    host = FactoryBot.create(:host, :managed)
    additional_interface = FactoryBot.build(:nic_managed, :without_ipv4)
    additional_interface.identifier = 'test_underscore_ignored'
    host.interfaces << additional_interface
    additional_interface = FactoryBot.build(:nic_managed, :without_ipv4)
    additional_interface.identifier = 'testXunderscore_ignored'
    host.interfaces << additional_interface
    host.save!

    assert_difference 'Nic::Base.unscoped.count', -1 do
      cleaner.clean!
    end

    assert_equal 1, cleaner.deleted_count
  end
end
