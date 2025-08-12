require 'test_helper'

class FilterTest < ActiveSupport::TestCase
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
      assert_empty filter.taxonomy_search
      Organization.current = original_org
    end

    test "removing all organizations and locations from filter nilify taxonomy search" do
      f = FactoryBot.create(:filter, :search => '')
      f.role = FactoryBot.build(:role, :locations => [@location], :organizations => [@organization, @organization1])
      f.save
      f.enforce_inherited_taxonomies
      f.role.update :organizations => [], :locations => []
      f.save
      f.enforce_inherited_taxonomies
      assert f.valid?
      assert_nil f.taxonomy_search
    end
  end

  test "#resource_taxable_by_*?" do
    # Filter is global resource
    ff = FactoryBot.create(:filter, :resource_type => 'Filter')
    fd = FactoryBot.create(:filter, :resource_type => 'Domain')
    refute ff.resource_taxable_by_organization?
    refute ff.resource_taxable_by_location?
    assert fd.resource_taxable_by_organization?
    assert fd.resource_taxable_by_location?
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

  test 'enforce_inherited_taxonomies builds the taxonomy search string' do
    f = FactoryBot.build(:filter, :resource_type => 'Domain')
    f.role = FactoryBot.build(:role, :organizations => [FactoryBot.build(:organization)])
    f.save # we need ids
    f.enforce_inherited_taxonomies
    assert_equal "(organization_id ^ (#{f.role.organizations.first.id}))", f.taxonomy_search
  end

  test 'saving nilifies empty taxonomy search' do
    f = FactoryBot.build(:filter, :resource_type => 'Domain')
    f.role = FactoryBot.build(:role)
    f.save
    assert_nil f.taxonomy_search
  end

  test 'creating a filter inherits taxonomies from the role' do
    f = FactoryBot.create(:filter, :resource_type => 'Domain')
    organization_test = FactoryBot.create(:organization)
    location_test = FactoryBot.create(:location)
    f.role = FactoryBot.create(:role, :organizations => [organization_test], :locations => [location_test])
    f.save
    assert_equal f.taxonomy_search, "(organization_id ^ (#{organization_test.id})) and (location_id ^ (#{location_test.id}))"
  end
end
