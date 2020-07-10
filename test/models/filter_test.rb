require 'test_helper'

class FilterTest < ActiveSupport::TestCase
  test "#unlimited?" do
    f = FactoryBot.build_stubbed :filter
    assert_nil f.search, 'default filter is not unlimited'
    assert f.unlimited?
  end

  test "#limited?" do
    f = FactoryBot.build_stubbed :filter, :on_name_all
    refute_nil f.search, 'filter is not limited'
    assert f.limited?
  end

  test "#limited? even for empty string" do
    f = FactoryBot.build_stubbed :filter
    f.search = ''
    assert f.limited?
  end

  test ".limited" do
    f = FactoryBot.create(:filter, :on_name_all)
    assert_include Filter.limited, f
  end

  test ".unlimited" do
    f = FactoryBot.create(:filter)
    assert_include Filter.unlimited, f
  end

  test '.search_for("limited = ..")' do
    f = FactoryBot.create(:filter, :on_name_all)
    assert_includes Filter.search_for('limited = true'), f
    refute_includes Filter.search_for('limited = false'), f
  end

  test '.search_for("unlimited = ..")' do
    f = FactoryBot.create(:filter)
    assert_includes Filter.search_for('unlimited = true'), f
    refute_includes Filter.search_for('unlimited = false'), f
  end

  test "#resource_type for empty permissions collection" do
    f = FactoryBot.build_stubbed(:filter)
    f.permissions = []
    assert_nil f.resource_type
  end

  test "#resource_type" do
    f = FactoryBot.build_stubbed(:filter)
    f.stub :filterings, [OpenStruct.new(:permission => OpenStruct.new(:resource_type => 'test'))] do
      assert_equal 'test', f.resource_type
    end
  end

  test ".get_resource_class known" do
    assert_equal Bookmark, Filter.get_resource_class('Bookmark')
  end

  test ".get_resource_class unknown" do
    assert_nil Filter.get_resource_class('BookmarkThatDoesNotExist')
  end

  test ".get_resource_class nil" do
    assert_nil Filter.get_resource_class(nil)
  end

  test "#resource_class" do
    f = FactoryBot.build_stubbed(:filter, :resource_type => 'Bookmark')
    Filter.stub :get_resource_class, Architecture do
      assert_equal Architecture, f.resource_class
    end
  end

  test "#granular? for unknown resource type" do
    f = FactoryBot.build_stubbed(:filter, :resource_type => 'BookmarkThatDoesNotExist')
    refute f.granular?
  end

  test "#granular?" do
    f = FactoryBot.build_stubbed(:filter, :resource_type => 'Domain')
    assert f.granular?
  end

  test "unlimited filters have nilified search string" do
    f = FactoryBot.build_stubbed(:filter, :search => 'name ~ a*', :unlimited => '1')
    assert f.valid?
    assert_nil f.search

    f = FactoryBot.build_stubbed(:filter, :search => '', :unlimited => '1')
    assert f.valid?
    assert_nil f.search

    f = FactoryBot.build_stubbed(:filter, :search => 'name ~ a*', :unlimited => '0')
    assert f.valid?
    assert_equal 'name ~ a*', f.search
  end

  context 'with taxnomies' do
    setup do
      as_admin do
        @organization = FactoryBot.create :organization
        @organization1 = FactoryBot.create :organization
        @location = FactoryBot.create :location
      end
    end

    test 'filter is not automatically scoped to any taxonomies' do
      original_org, Organization.current = Organization.current, @organization
      filter = Filter.new
      assert_empty filter.organizations
      Organization.current = original_org
    end

    test "filter with organization set is always limited before validation" do
      f = FactoryBot.build_stubbed(:filter, :search => '', :unlimited => '1', :organization_ids => [@organization.id])
      assert f.valid?
      assert f.limited?
      assert_include f.taxonomy_search, "(organization_id ^ (#{@organization.id}))"
      assert_not_include f.taxonomy_search, ' and '
      assert_not_include f.taxonomy_search, ' or '
    end

    test "filter with location set is always limited before validation" do
      f = FactoryBot.build_stubbed(:filter, :search => '', :unlimited => '1', :location_ids => [@location.id])
      assert f.valid?
      assert f.limited?
      assert_include f.taxonomy_search, "(location_id ^ (#{@location.id}))"
    end

    test "filter with location set is always limited before validation" do
      f = FactoryBot.build_stubbed(:filter, :search => '', :unlimited => '1',
                         :organization_ids => [@organization.id, @organization1.id], :location_ids => [@location.id])
      assert f.valid?
      assert f.limited?
      assert_equal "(organization_id ^ (#{@organization.id},#{@organization1.id})) and (location_id ^ (#{@location.id}))", f.taxonomy_search
    end

    test "removing all organizations and locations from filter nilify taxonomy search" do
      f = FactoryBot.create(:filter, :search => '', :unlimited => '1',
                          :organization_ids => [@organization.id, @organization1.id], :location_ids => [@location.id])

      f.update :organization_ids => [], :location_ids => []
      assert f.valid?
      assert f.unlimited?
      assert_nil f.taxonomy_search
    end

    test "taxonomies can be assigned only if resource allows it" do
      fb = FactoryBot.build_stubbed(:filter, :resource_type => 'Bookmark', :organization_ids => [@organization.id])
      fd = FactoryBot.build_stubbed(:filter, :resource_type => 'Domain', :organization_ids => [@organization.id])
      refute_valid fb
      assert_valid fd
      fb = FactoryBot.create(:filter, :resource_type => 'Bookmark')
      fd = FactoryBot.create(:filter, :resource_type => 'Domain')
      fb.location_ids = [@location.id]
      refute_valid fb
      fd.location_ids = [@location.id]
      assert_valid fd
    end
  end

  test "filter remains unlimited when no organization assigned" do
    f = FactoryBot.build_stubbed(:filter, :search => '', :unlimited => '1', :organization_ids => [])
    assert f.valid?
    assert f.unlimited?
    assert_empty f.taxonomy_search
  end

  test "filter remains set to unlimited when no taxonomy assigned and has empty search" do
    f = FactoryBot.build_stubbed(:filter, :search => '', :unlimited => '0', :organization_ids => [],
                      :location_ids => [])
    assert f.valid?
    assert f.unlimited?
    assert_empty f.taxonomy_search
  end

  test "#allows_*_filtering" do
    fb = FactoryBot.create(:filter, :resource_type => 'Bookmark')
    fd = FactoryBot.create(:filter, :resource_type => 'Domain')
    refute fb.allows_organization_filtering?
    refute fb.allows_location_filtering?
    assert fd.allows_organization_filtering?
    assert fd.allows_location_filtering?
  end

  test "search string composition" do
    f = FactoryBot.build_stubbed :filter, :search => nil, :taxonomy_search => nil
    assert_equal '', f.search_condition

    f = FactoryBot.build_stubbed :filter, :search => 'domain ~ test*', :taxonomy_search => nil
    assert_equal 'domain ~ test*', f.search_condition

    f = FactoryBot.build_stubbed :filter, :search => nil, :taxonomy_search => 'organization_id = 1'
    assert_equal 'organization_id = 1', f.search_condition

    f = FactoryBot.build_stubbed :filter, :search => 'domain ~ test*', :taxonomy_search => 'organization_id = 1'
    assert_equal '(domain ~ test*) and (organization_id = 1)', f.search_condition
  end

  test "filter with a valid search string is valid" do
    f = FactoryBot.build_stubbed(:filter, :search => "name = 'blah'", :resource_type => 'Domain')
    assert_valid f
  end

  test "filter with an invalid search string is invalid" do
    f = FactoryBot.build_stubbed(:filter, :search => "non_existent = 'blah'", :resource_type => 'Domain')
    refute_valid f
  end

  test "filter with an empty search string is valid" do
    f = FactoryBot.build_stubbed(:filter, :search => nil, :resource_type => 'Domain')
    assert_valid f
  end

  test 'disable overriding recalculates taxonomies' do
    f = FactoryBot.build(:filter, :resource_type => 'Domain')
    f.role = FactoryBot.build(:role, :organizations => [FactoryBot.build(:organization)])
    assert_empty f.organizations
    f.disable_overriding!
    refute f.override
    assert_equal f.organizations, f.role.organizations
  end

  test 'enforce_inherited_taxonomies respects override configuration' do
    f = FactoryBot.build(:filter, :resource_type => 'Domain', :override => true)
    f.role = FactoryBot.build(:role, :organizations => [FactoryBot.build(:organization)])
    f.save # we need ids
    f.enforce_inherited_taxonomies
    assert_empty f.organizations
    f.override = false
    f.enforce_inherited_taxonomies
    assert_equal f.role.organizations, f.organizations
  end

  test 'enforce_inherited_taxonomies builds the taxonomy search string' do
    f = FactoryBot.build(:filter, :resource_type => 'Domain')
    f.role = FactoryBot.build(:role, :organizations => [FactoryBot.build(:organization)])
    f.save # we need ids
    f.enforce_inherited_taxonomies
    assert_equal "(organization_id ^ (#{f.organizations.first.id}))", f.taxonomy_search
  end

  test 'saving nilifies empty taxonomy search' do
    f = FactoryBot.build(:filter, :resource_type => 'Domain')
    f.role = FactoryBot.build(:role, :organizations => [FactoryBot.build(:organization)])
    f.save
    assert_nil f.taxonomy_search
  end
end
