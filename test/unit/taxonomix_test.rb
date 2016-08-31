require 'test_helper'

class TaxonomixDummy < ActiveRecord::Base
  self.table_name = 'environments'
  include Taxonomix

  attr_accessor :locations, :organizations
  after_initialize :set_taxonomies_to_empty

  def set_taxonomies_to_empty
    self.locations = []
    self.organizations = []
  end
end

class UntaxedDummy < ActiveRecord::Base
  self.table_name = 'environments'
end

class InheritingTaxonomixDummy < UntaxedDummy
  include Taxonomix
end

class TaxonomixTest < ActiveSupport::TestCase
  def setup
    @dummy = TaxonomixDummy.new
    Taxonomy.stubs(:enabled?).with(:location).returns(false)
    Taxonomy.stubs(:enabled?).with(:organization).returns(true)
  end

  test "STI is properly supported" do
    TaxableTaxonomy.expects(:where).with({ :taxable_type => 'UntaxedDummy' }).returns(TaxableTaxonomy.all)
    InheritingTaxonomixDummy.inner_select(nil, :subtree_ids)
  end

  test "#add_current_taxonomy? returns false for disabled taxonomy" do
    refute @dummy.add_current_taxonomy?(:location)
  end

  test "#add_current_taxonomy? returns false for unset current taxonomy" do
    Organization.stubs(:current).returns(nil)
    refute @dummy.add_current_taxonomy?(:organization)
  end

  test "#add_current_taxonomy? returns false when current taxonomy already assigned" do
    Organization.stubs(:current).returns(taxonomies(:organization1))
    @dummy.organizations = [taxonomies(:organization1)]
    refute @dummy.add_current_taxonomy?(:organization)
  end

  test "#add_current_taxonomy? returns true otherwise" do
    Organization.stubs(:current).returns(taxonomies(:organization1))
    Organization.stubs(:organizations).returns([])
    assert @dummy.add_current_taxonomy?(:organization)
  end

  test "#set_current_taxonomy" do
    Organization.stubs(:current).returns(taxonomies(:organization1))
    @dummy.set_current_taxonomy
    assert_includes @dummy.organizations, taxonomies(:organization1)
    assert_empty @dummy.locations
  end

  test ".with_taxonomy_scope expands organizations and locations to actual values" do
    org1 = FactoryGirl.create(:organization)
    org2 = FactoryGirl.create(:organization)
    org3 = FactoryGirl.create(:organization)
    user = FactoryGirl.create(:user, :organizations => [org1, org2])
    dummy_class = @dummy.class

    as_user(user) do
      dummy_class.with_taxonomy_scope(nil, nil)
    end

    assert_empty dummy_class.which_location
    assert_includes dummy_class.which_organization, org1
    assert_includes dummy_class.which_organization, org2
    refute_includes dummy_class.which_organization, org3
  end

  test ".used_location_ids can work with array of locations" do
    loc1 = FactoryGirl.create(:location)
    loc2 = FactoryGirl.create(:location, :parent_id => loc1.id)
    loc3 = FactoryGirl.create(:location, :parent_id => loc2.id)
    loc4 = FactoryGirl.create(:location)
    dummy_class = @dummy.class
    dummy_class.which_ancestry_method = :subtree_ids

    dummy_class.which_location = []
    used_locations = dummy_class.used_location_ids
    assert_empty used_locations

    dummy_class.which_location = [loc2]
    used_locations = dummy_class.used_location_ids
    assert_includes used_locations, loc1.id
    assert_includes used_locations, loc2.id
    assert_includes used_locations, loc3.id
    refute_includes used_locations, loc4.id

    dummy_class.which_location = [loc2, loc4]
    used_locations = dummy_class.used_location_ids
    assert_includes used_locations, loc1.id
    assert_includes used_locations, loc2.id
    assert_includes used_locations, loc3.id
    assert_includes used_locations, loc4.id
  end

  test ".used_organization_ids can work with array of organizations" do
    org1 = FactoryGirl.create(:organization)
    org2 = FactoryGirl.create(:organization, :parent_id => org1.id)
    org3 = FactoryGirl.create(:organization, :parent_id => org2.id)
    org4 = FactoryGirl.create(:organization)
    dummy_class = @dummy.class
    dummy_class.which_ancestry_method = :subtree_ids

    dummy_class.which_organization = []
    used_organizations = dummy_class.used_organization_ids
    assert_empty used_organizations

    dummy_class.which_organization = [org2]
    used_organizations = dummy_class.used_organization_ids
    assert_includes used_organizations, org1.id
    assert_includes used_organizations, org2.id
    assert_includes used_organizations, org3.id
    refute_includes used_organizations, org4.id

    dummy_class.which_organization = [org2, org4]
    used_organizations = dummy_class.used_organization_ids
    assert_includes used_organizations, org1.id
    assert_includes used_organizations, org2.id
    assert_includes used_organizations, org3.id
    assert_includes used_organizations, org4.id
  end

  test ".taxable_ids can work with empty array returning nil" do
    dummy_class = @dummy.class
    assert_nil dummy_class.taxable_ids([], [])
  end

  test ".taxable_ids (and .inner_select) can work with array of taxonomies" do
    loc1 = FactoryGirl.create(:location)
    loc2 = FactoryGirl.create(:location, :parent_id => loc1.id)
    loc3 = FactoryGirl.create(:location, :parent_id => loc2.id)
    loc4 = FactoryGirl.create(:location)
    org = FactoryGirl.create(:organization)
    env1 = FactoryGirl.create(:environment, :organizations => [org], :locations => [loc2])
    env2 = FactoryGirl.create(:environment, :organizations => [org])
    env3 = FactoryGirl.create(:environment, :locations => [loc2])
    env4 = FactoryGirl.create(:environment, :locations => [loc4])
    env5 = FactoryGirl.create(:environment, :locations => [loc1])
    env6 = FactoryGirl.create(:environment, :locations => [loc3])

    taxable_ids = Environment.taxable_ids([loc2, loc4], org, :subtree_ids)
    visible = [ env1 ]
    invisible = [ env2, env3, env4, env5, env6 ]
    visible.each { |env| assert_includes taxable_ids, env.id }
    invisible.each { |env| refute_includes taxable_ids, env.id }

    taxable_ids = Environment.taxable_ids([], org, :subtree_ids)
    visible = [ env1, env2 ]
    invisible = [ env3, env4, env5, env6 ]
    visible.each { |env| assert_includes taxable_ids, env.id }
    invisible.each { |env| refute_includes taxable_ids, env.id }

    taxable_ids = Environment.taxable_ids(loc2, [], :subtree_ids)
    visible = [ env1, env3, env5, env6 ]
    invisible = [ env2, env4 ]
    visible.each { |env| assert_includes taxable_ids, env.id }
    invisible.each { |env| refute_includes taxable_ids, env.id }

    taxable_ids = Environment.taxable_ids([loc2, loc4], [], :subtree_ids)
    visible = [ env1, env3, env4, env5, env6 ]
    invisible = [ env2 ]
    visible.each { |env| assert_includes taxable_ids, env.id }
    invisible.each { |env| refute_includes taxable_ids, env.id }
  end

  test "validation does not prevent taxonomy association if user does not have permissions of already assigned taxonomies" do
    filter = FactoryGirl.create(:filter, :search => 'name ~ visible*')
    filter.permissions = Permission.where(:name => [ 'view_organizations', 'assign_organizations' ])
    role = FactoryGirl.create(:role)
    role.filters = [ filter ]

    user = FactoryGirl.create(:user)
    user.roles = [ role ]
    org1 = FactoryGirl.create :organization, :name => 'visible1'
    org2 = FactoryGirl.create :organization, :name => 'visible2'
    org3 = FactoryGirl.create :organization, :name => 'hidden'
    user.organizations = [ org1 ]

    resource = FactoryGirl.create(:domain, :organizations => [ org1, org3 ])
    assert_includes resource.organizations, org3

    as_user user do
      resource.organization_ids = [ org1, org2, org3 ].map(&:id)
      assert resource.save!
    end

    assert_includes resource.organizations, org1
    assert_includes resource.organizations, org2
    assert_includes resource.organizations, org3
  end

  test "default scope does not set create scope attributes" do
    org = FactoryGirl.create :organization
    FactoryGirl.create(:domain, :organizations => [ org ])
    original_org, Organization.current = Organization.current, org
    new_dom = Domain.new(:organization_ids => [ org.id ])
    Organization.current = original_org
    new_dom.taxable_taxonomies.must_be :present?
    assert new_dom.taxable_taxonomies.all?(&:valid?)
  end
end
