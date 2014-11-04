require 'test_helper'

class ManagedTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
  end

  test '#setup_clone skips new records' do
    assert_nil FactoryGirl.build(:nic_managed).send(:setup_clone)
  end

  test '#setup_clone clones host as well' do
    host = FactoryGirl.create(:host, :comment => 'original')
    nic = FactoryGirl.create(:nic_managed, :host => host)
    nic.host.comment = 'updated'
    clone = nic.send(:setup_clone)
    refute_equal clone.host.object_id, nic.host.object_id
    assert_equal 'updated', nic.host.comment
    assert_equal 'original', clone.host.comment
  end
end
