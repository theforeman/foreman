require 'test_helper'

class HostConfigGroupTest < ActiveSupport::TestCase
  should belong_to(:host)
  should belong_to(:config_group)
  should validate_uniqueness_of(:host_id).scoped_to(:config_group_id, :host_type)

  test 'relationship host.config_groups ' do
    c1 = FactoryBot.create(:config_group)
    c2 = FactoryBot.create(:config_group)
    host = FactoryBot.create(:host, :config_groups => [c1, c2])
    assert_equal 2, host.config_groups.count
    assert_equal [c1.name, c2.name].sort, host.config_groups.pluck(:name).sort
  end

  test 'relationship hostgroup.config_groups' do
    hostgroup = hostgroups(:common)
    assert_equal 2, hostgroup.config_groups.count
    assert_equal ['Monitoring', 'Tools'].sort, hostgroup.config_groups.pluck(:name).sort
  end
end
