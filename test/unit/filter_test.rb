require 'test_helper'

class FilterTest < ActiveSupport::TestCase
  test "#unlimited?" do
    f = Factory.build :filter
    assert_nil f.search, 'default filter is not unlimited'
    assert f.unlimited?
  end

  test "#limited?" do
    f = Factory.build :filter, :on_name_all
    refute_nil f.search, 'filter is not limited'
    assert f.limited?
  end

  test "#limited? even for empty string" do
    f = Factory.build :filter
    f.search = ''
    assert f.limited?
  end

  test ".limited" do
    f = Factory.create(:filter, :on_name_all)
    assert_include Filter.limited, f
  end

  test ".unlimited" do
    f = Factory.create(:filter)
    assert_include Filter.unlimited, f
  end

  test "#resource_type for empty permissions collection" do
    f = Factory.build(:filter)
    f.permissions = []
    assert_nil f.resource_type
  end

  test "#resource_type" do
    f = Factory.build(:filter)
    f.stub :permissions, [ OpenStruct.new(:resource_type => 'test') ] do
      assert_equal 'test', f.resource_type
    end
  end

  test ".get_resource_class known" do
    assert_equal Bookmark, Filter.get_resource_class('Bookmark')
  end

  test ".get_resource_class unknown" do
    assert_nil Filter.get_resource_class('BookmarkThatDoesNotExist')
  end

  test "#resource_class" do
    f = Factory.build(:filter, :resource_type => 'Bookmark')
    Filter.stub :get_resource_class, Architecture do
      assert_equal Architecture, f.resource_class
    end
  end

  test "#granular? for unknown resource type" do
    f = Factory.build(:filter, :resource_type => 'BookmarkThatDoesNotExist')
    refute f.granular?
  end

  test "#granular?" do
    f = Factory.build(:filter, :resource_type => 'Domain')
    assert f.granular?
  end

  test "unlimited filters have nilified search string" do
    f = Factory.build(:filter, :search => 'name ~ a*', :unlimited => '1')
    assert f.valid?
    assert_nil f.search

    f = Factory.build(:filter, :search => '', :unlimited => '1')
    assert f.valid?
    assert_nil f.search

    f = Factory.build(:filter, :search => 'name ~ a*', :unlimited => '0')
    assert f.valid?
    assert_equal 'name ~ a*', f.search
  end

  test "filter with organization set is always limited before validation" do
    o = Factory.create :organization
    f = Factory.build(:filter, :search => '', :unlimited => '1', :organization_ids => [o.id])
    assert f.valid?
    assert f.limited?
    assert_include f.taxonomy_search, "(organization_id = #{o.id})"
    assert_not_include f.taxonomy_search, ' and '
    assert_not_include f.taxonomy_search, ' or '
  end

  test "filter remains unlimited when no organization assigned" do
    f = Factory.build(:filter, :search => '', :unlimited => '1', :organization_ids => [])
    assert f.valid?
    assert f.unlimited?
    assert_empty f.taxonomy_search
  end

  test "filter remains set to unlimited when no taxonomy assigned and has empty search" do
    f = Factory.build(:filter, :search => '', :unlimited => '0', :organization_ids => [],
                      :location_ids => [])
    assert f.valid?
    assert f.unlimited?
    assert_empty f.taxonomy_search
  end

  test "filter with location set is always limited before validation" do
    l = Factory.create :location
    f = Factory.build(:filter, :search => '', :unlimited => '1', :location_ids => [l.id])
    assert f.valid?
    assert f.limited?
    assert_include f.taxonomy_search, "(location_id = #{l.id})"
  end

  test "filter with location set is always limited before validation" do
    o1 = Factory.create :organization
    o2 = Factory.create :organization
    l  = Factory.create :location
    f  = Factory.build(:filter, :search => '', :unlimited => '1',
                       :organization_ids => [o1.id, o2.id], :location_ids => [l.id])
    assert f.valid?
    assert f.limited?
    assert_include f.taxonomy_search, "(location_id = #{l.id})"
    assert_include f.taxonomy_search, "organization_id = #{o1.id}"
    assert_include f.taxonomy_search, "organization_id = #{o2.id}"
  end

  test "removing all organizations and locations from filter nilify taxonomy search" do
    o1 = Factory.create :organization
    o2 = Factory.create :organization
    l  = Factory.create :location
    f  = Factory.create(:filter, :search => '', :unlimited => '1',
                        :organization_ids => [o1.id, o2.id], :location_ids => [l.id])

    f.update_attributes :organization_ids => [], :location_ids => []
    assert f.valid?
    assert f.unlimited?
    assert_nil f.taxonomy_search
  end

  test "taxonomies are ignored if resource does not support them" do
    o1 = Factory.create :organization
    o2 = Factory.create :organization
    l = Factory.create :location
    f = Factory.create(:filter, :search => '', :unlimited => '1',
                       :organization_ids => [o1.id, o2.id], :location_ids => [l.id],
                       :resource_type => 'Bookmark')

    f.reload
    assert f.valid?
    assert f.unlimited?
    assert_nil f.taxonomy_search
  end

  test "#allows_*_filtering" do
    fb = Factory.create(:filter, :resource_type => 'Bookmark')
    fd = Factory.create(:filter, :resource_type => 'Domain')
    refute fb.allows_organization_filtering?
    refute fb.allows_location_filtering?
    assert fd.allows_organization_filtering?
    assert fd.allows_location_filtering?
  end

  test "search string composition" do
    f = Factory.build :filter, :search => nil, :taxonomy_search => nil
    assert_equal '', f.search_condition

    f = Factory.build :filter, :search => 'domain ~ test*', :taxonomy_search => nil
    assert_equal 'domain ~ test*', f.search_condition

    f = Factory.build :filter, :search => nil, :taxonomy_search => 'organization_id = 1'
    assert_equal 'organization_id = 1', f.search_condition

    f = Factory.build :filter, :search => 'domain ~ test*', :taxonomy_search => 'organization_id = 1'
    assert_equal '(domain ~ test*) and (organization_id = 1)', f.search_condition
  end

end
