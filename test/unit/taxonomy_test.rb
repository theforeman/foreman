require 'test_helper'

class TaxonomyTest < ActiveSupport::TestCase
  def setup
    SETTINGS.stubs(:[]).with(:organizations_enabled).returns(true)
    SETTINGS.stubs(:[]).with(:locations_enabled).returns(false)
  end

  test '.enabled?' do
    assert Taxonomy.enabled?(:organization)
    refute Taxonomy.enabled?(:location)
  end

  test '.locations_enabled' do
    refute Taxonomy.locations_enabled
  end

  test '.organizations_enabled' do
    assert Taxonomy.organizations_enabled
  end

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
    org = FactoryGirl.build(:organization)
    as_admin do
      assert_equal org, Taxonomy.expand(org)
    end
  end

  test 'does not expand if no user set' do
    org1 = FactoryGirl.build(:organization)
    org2 = FactoryGirl.build(:organization)
    assert_equal nil, Taxonomy.expand(nil)
    assert_equal [], Taxonomy.expand([])
    assert_equal org1, Taxonomy.expand(org1)
    assert_equal [org1, org2], Taxonomy.expand([org1, org2])
  end

  test 'for non admin user, nil is expanded to user assigned taxonomies' do
    # we have to run on specific taxonomy because my_* is defined only in Organization and Location
    org1 = FactoryGirl.create(:organization)
    org2 = FactoryGirl.create(:organization)
    FactoryGirl.create(:organization) # this one won't be expanded
    user = FactoryGirl.create(:user, :organizations => [org1, org2])
    as_user(user) do
      assert_equal [org1, org2], Organization.expand(nil)
      assert_equal [org1, org2], Organization.expand([])
    end
  end

  test 'for non admin user, nil is expanded to [] if user is not assigned to any org' do
    # we have to run on specific taxonomy because my_* is defined only in Organization and Location
    user = FactoryGirl.create(:user)
    as_user(user) do
      assert_equal [], Organization.expand(nil)
      assert_equal [], Organization.expand([])
    end
  end

  test 'for non admin user, expand return the specified taxonomy' do
    # we have to run on specific taxonomy because my_* is defined only in Organization and Location
    org1 = FactoryGirl.create(:organization)
    org2 = FactoryGirl.create(:organization)
    user = FactoryGirl.create(:user, :organizations => [org1, org2])
    as_user(user) do
      assert_equal org1, Organization.expand(org1)
      assert_equal [org1, org2], Organization.expand([org1, org2])
    end
  end
end
