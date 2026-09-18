require 'test_helper'

class HostgroupSubtreeCountsTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
  end

  test 'aggregates direct and descendant host counts for roots and leaves' do
    root = FactoryBot.create(:hostgroup, :with_os, :with_domain)
    leaf = FactoryBot.create(:hostgroup, :parent => root)
    empty = FactoryBot.create(:hostgroup, :with_os, :with_domain)

    FactoryBot.create_list(:host, 2, :managed, :hostgroup => root)
    FactoryBot.create_list(:host, 3, :managed, :hostgroup => leaf)

    counts = HostgroupSubtreeCounts.new(Hostgroup.unscoped).totals

    assert_equal 5, counts[root.id]
    assert_equal 3, counts[leaf.id]
    assert_equal 0, counts.fetch(empty.id, 0)
  end

  test 'limits aggregation to the requested target hostgroups' do
    root = FactoryBot.create(:hostgroup, :with_os, :with_domain)
    leaf = FactoryBot.create(:hostgroup, :parent => root)
    unrelated = FactoryBot.create(:hostgroup, :with_os, :with_domain)

    FactoryBot.create_list(:host, 2, :managed, :hostgroup => root)
    FactoryBot.create_list(:host, 3, :managed, :hostgroup => leaf)
    FactoryBot.create_list(:host, 4, :managed, :hostgroup => unrelated)

    counts = HostgroupSubtreeCounts.new(
      Hostgroup.unscoped,
      target_hostgroups: [root]
    ).totals

    assert_equal 5, counts[root.id]
    refute counts.key?(leaf.id)
    refute counts.key?(unrelated.id)
  end
end
