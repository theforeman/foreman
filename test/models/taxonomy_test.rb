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
    assert_empty Taxonomy.expand([])
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
      assert_empty Organization.expand(nil)
      assert_empty Organization.expand([])
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

  test 'batch_subtree_ids returns empty array for empty input' do
    assert_empty Taxonomy.batch_subtree_ids([])
  end

  test 'batch_subtree_ids returns subtree for a single taxonomy' do
    parent = FactoryBot.create(:organization)
    child = FactoryBot.create(:organization, parent: parent)
    grandchild = FactoryBot.create(:organization, parent: child)

    result = Taxonomy.batch_subtree_ids([parent])
    assert_equal [parent.id, child.id, grandchild.id].sort, result
  end

  test 'batch_subtree_ids returns union of subtrees for multiple taxonomies' do
    org1 = FactoryBot.create(:organization)
    org1_child = FactoryBot.create(:organization, parent: org1)
    org2 = FactoryBot.create(:organization)
    org2_child = FactoryBot.create(:organization, parent: org2)

    result = Taxonomy.batch_subtree_ids([org1, org2])
    assert_equal [org1.id, org1_child.id, org2.id, org2_child.id].sort, result
  end

  test 'batch_subtree_ids handles overlapping subtrees' do
    parent = FactoryBot.create(:organization)
    child = FactoryBot.create(:organization, parent: parent)
    grandchild = FactoryBot.create(:organization, parent: child)

    result = Taxonomy.batch_subtree_ids([parent, child])
    assert_equal [parent.id, child.id, grandchild.id].sort, result
  end

  test 'batch_subtree_ids returns deterministic order' do
    orgs = Array.new(3) { FactoryBot.create(:organization) }
    result = Taxonomy.batch_subtree_ids(orgs)
    assert_equal 3, result.size
    assert_equal result.sort, result
  end

  test 'potentially_ignoring returns taxonomies that ignore the given type' do
    ignoring = FactoryBot.create(:organization, ignore_types: ['User'])
    not_ignoring = FactoryBot.create(:organization, ignore_types: [])

    result = Organization.unscoped.potentially_ignoring('user')
    assert_includes result, ignoring
    refute_includes result, not_ignoring
  end

  test 'batch_subtree_ids matches individual subtree_ids' do
    parent = FactoryBot.create(:organization)
    child = FactoryBot.create(:organization, parent: parent)
    FactoryBot.create(:organization, parent: child)
    standalone = FactoryBot.create(:organization)

    inputs = [parent, child, standalone]
    assert_equal inputs.flat_map(&:subtree_ids).uniq.sort,
      Taxonomy.batch_subtree_ids(inputs)
  end

  test 'batch_subtree_ids returns only the given node for a leaf taxonomy' do
    leaf = FactoryBot.create(:organization)
    assert_equal [leaf.id], Taxonomy.batch_subtree_ids([leaf])
  end

  test 'batch_subtree_ids raises on mixed taxonomy types' do
    org = FactoryBot.create(:organization)
    loc = FactoryBot.create(:location)
    assert_raises(ArgumentError) { Taxonomy.batch_subtree_ids([org, loc]) }
  end

  test 'batch_subtree_ids raises on unsaved records' do
    org = FactoryBot.build(:organization)
    assert_raises(ArgumentError) { Taxonomy.batch_subtree_ids([org]) }
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
