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
end
