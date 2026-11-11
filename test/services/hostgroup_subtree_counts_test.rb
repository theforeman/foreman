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

  test 'handles deep nesting with 5+ levels correctly' do
    level1 = FactoryBot.create(:hostgroup, :with_os, :with_domain)
    level2 = FactoryBot.create(:hostgroup, :parent => level1)
    level3 = FactoryBot.create(:hostgroup, :parent => level2)
    level4 = FactoryBot.create(:hostgroup, :parent => level3)
    level5 = FactoryBot.create(:hostgroup, :parent => level4)
    level6 = FactoryBot.create(:hostgroup, :parent => level5)

    FactoryBot.create(:host, :managed, :hostgroup => level1)
    FactoryBot.create(:host, :managed, :hostgroup => level3)
    FactoryBot.create(:host, :managed, :hostgroup => level6)

    counts = HostgroupSubtreeCounts.new(Hostgroup.unscoped).totals

    assert_equal 3, counts[level1.id], "level1 should count all descendants"
    assert_equal 2, counts[level2.id], "level2 should count level3 and level6"
    assert_equal 2, counts[level3.id], "level3 should count self and level6"
    assert_equal 1, counts[level4.id], "level4 should count only level6"
    assert_equal 1, counts[level5.id], "level5 should count only level6"
    assert_equal 1, counts[level6.id], "level6 should count only self"
  end

  test 'correctly aggregates when middle levels have no hosts' do
    root = FactoryBot.create(:hostgroup, :with_os, :with_domain)
    middle_empty = FactoryBot.create(:hostgroup, :parent => root)
    leaf = FactoryBot.create(:hostgroup, :parent => middle_empty)

    FactoryBot.create_list(:host, 2, :managed, :hostgroup => root)
    FactoryBot.create_list(:host, 3, :managed, :hostgroup => leaf)

    counts = HostgroupSubtreeCounts.new(Hostgroup.unscoped).totals

    assert_equal 5, counts[root.id], "root should aggregate all descendants"
    assert_equal 3, counts[middle_empty.id], "empty middle should still aggregate leaf"
    assert_equal 3, counts[leaf.id], "leaf counts itself"
  end
end
