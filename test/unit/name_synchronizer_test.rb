require 'test_helper'

class NameSynchronizerName < ActiveSupport::TestCase
  def setup
    @host = FactoryGirl.build(:host, :managed)
    @nic  = FactoryGirl.build(:nic_managed, :host => @host, :name => 'myname', :primary => true)
    @hsync = NameSynchronizer.new(@host)
    @nsync = NameSynchronizer.new(@nic)
  end

  context 'synchronizer build from host' do
    test '#sync_required? detects difference between names' do
      refute_equal @host.name, @host.primary_interface.name
      assert @hsync.sync_required?
    end

    test '#sync_name synchronizes name based on interface' do
      refute_equal @host.name, @host.primary_interface.name
      @hsync.sync_name
      assert_nil @host.primary_interface.name
      assert_nil @host.name
    end
  end

  context 'synchronizer build from nic' do
    test '#sync_required? detects difference between names' do
      refute_equal @nic.name, @nic.host.name
      assert @nsync.sync_required?
    end

    test '#sync_name synchronizes name based on interface' do
      refute_equal @nic.name, @nic.host.name
      @nsync.sync_name
      assert_equal @nic.name, @nic.host.name
      assert_equal 'myname', @nic.host.name
    end
  end

  test 'synchronization is not triggered for other than primary interfaces' do
    nic = FactoryGirl.build(:nic_managed, :host => @host, :name => 'myname', :primary => false)
    sync = NameSynchronizer.new(nic)
    refute_equal nic.name, nic.host.name
    refute sync.sync_required?
  end
end
