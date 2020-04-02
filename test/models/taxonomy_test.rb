require 'test_helper'

class TaxonomyTest < ActiveSupport::TestCase
  should validate_presence_of(:name)
  should validate_uniqueness_of(:name).scoped_to(:ancestry, :type).case_insensitive

  test 'expand return [] for admin if no taxonomy set' do
    as_admin do
      assert_empty Taxonomy.expand(nil)
    end
  end

  test 'expand return [] for admin if empty set of taxonomies set' do
    as_admin do
      assert_empty Taxonomy.expand([])
    end
  end

  test 'expand return the specified taxonomy for admin' do
    org = FactoryBot.build_stubbed(:organization)
    as_admin do
      assert_equal org, Taxonomy.expand(org)
    end
  end

  test 'does not expand if no user set' do
    org1 = FactoryBot.build_stubbed(:organization)
    org2 = FactoryBot.build_stubbed(:organization)
    assert_nil Taxonomy.expand(nil)
    assert_equal [], Taxonomy.expand([])
    assert_equal org1, Taxonomy.expand(org1)
    assert_equal [org1, org2], Taxonomy.expand([org1, org2])
  end

  test 'for non admin user, nil is expanded to user assigned taxonomies' do
    # we have to run on specific taxonomy because my_* is defined only in Organization and Location
    org1 = FactoryBot.create(:organization)
    org2 = FactoryBot.create(:organization)
    FactoryBot.create(:organization) # this one won't be expanded
    user = FactoryBot.create(:user, :organizations => [org1, org2])
    as_user(user) do
      assert_equal [org1, org2].sort, Organization.expand(nil).sort
      assert_equal [org1, org2].sort, Organization.expand([]).sort
    end
  end

  test 'for non admin user, nil is expanded to [] if user is not assigned to any org' do
    # we have to run on specific taxonomy because my_* is defined only in Organization and Location
    user = FactoryBot.create(:user, :organizations => [])
    as_user(user) do
      assert_equal [], Organization.expand(nil)
      assert_equal [], Organization.expand([])
    end
  end

  test 'for non admin user, expand return the specified taxonomy' do
    # we have to run on specific taxonomy because my_* is defined only in Organization and Location
    org1 = FactoryBot.create(:organization)
    org2 = FactoryBot.create(:organization)
    user = FactoryBot.create(:user, :organizations => [org1, org2])
    as_user(user) do
      assert_equal org1, Organization.expand(org1)
      assert_equal [org1, org2], Organization.expand([org1, org2])
    end
  end

  test "taxonomy cannot be saved with orphans" do
    location = Location.create :name => "Velky Tynec"
    organization = Organization.create :name => "Olomouc"
    FactoryBot.create(:host, :organization => organization, :location => location)
    organization.save
    assert_match /expecting locations/, organization.errors.messages[:locations].first
    location.save
    assert_match /expecting organizations/, location.errors.messages[:organizations].first
  end

  test "#taxonomy_ids_by_ignore_type should return ids of taxonomy_type for which 'Select All' option is checked for a resource." do
    FactoryBot.create(:organization, :ignore_types => ['User'])
    user = FactoryBot.create(:user, :id => 20)
    organization_ids_with_select_all = Organization.taxonomy_ids_by_ignore_type(user.class.to_s)
    assert_not organization_ids_with_select_all.empty?
    assert_equal organization_ids_with_select_all.count, 1
  end

  test "#add_references_for_selected_ignore_types assigns all objects of selected ignore_types to taxonomy" do
    user = FactoryBot.create(:user, :login => 'foo_test_u1')
    org1 = FactoryBot.create(:organization, :ignore_types => ['User'])
    assert_includes org1.user_ids, user.id
  end

  test "taxonomy created with ignore_type Domain, this taxonomy will get assign to all new domains created after it" do
    org1 = FactoryBot.create(:organization, :ignore_types => ['Domain'], :name => "Test_OrgA")
    domain1 = FactoryBot.create(:domain, :name => 'test-domain.com')
    assert_includes domain1.organization_ids, org1.id
  end
end
