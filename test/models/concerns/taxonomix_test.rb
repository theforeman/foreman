require 'test_helper'

class TaxonomixDummy < ApplicationRecord
  self.table_name = 'environments'
  include Taxonomix

  attr_accessor :locations, :organizations
  after_initialize :set_taxonomies_to_empty

  def set_taxonomies_to_empty
    self.locations = []
    self.organizations = []
  end
end

class UntaxedDummy < ApplicationRecord
  self.table_name = 'environments'
end

class InheritingTaxonomixDummy < UntaxedDummy
  include Taxonomix
end

class TaxonomixTest < ActiveSupport::TestCase
  def setup
    @dummy = TaxonomixDummy.new
  end

  test "STI is properly supported" do
    TaxableTaxonomy.expects(:where).with({ :taxable_type => 'UntaxedDummy' }).returns(TaxableTaxonomy.all)
    InheritingTaxonomixDummy.inner_select(nil, :subtree_ids)
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
    assert_includes @dummy.organization_ids, taxonomies(:organization1).id
    assert_empty @dummy.location_ids
  end

  describe '.with_taxonomy_scope' do
    setup do
      @org = FactoryBot.create(:organization)
      @loc = FactoryBot.create(:location)
    end

    test 'expands organizations and locations to actual values' do
      org2 = FactoryBot.create(:organization)
      org3 = FactoryBot.create(:organization)
      user = FactoryBot.create(:user, :organizations => [@org, org2],
                                :locations => [])

      as_user(user) do
        @dummy.class.with_taxonomy_scope(nil, nil)
      end

      assert_empty @dummy.class.which_location
      assert_includes @dummy.class.which_organization, @org
      assert_includes @dummy.class.which_organization, org2
      refute_includes @dummy.class.which_organization, org3
    end

    test 'does not return anything if no taxable IDs were found' do
      TaxonomixDummy.expects(:taxable_ids).returns([]).at_least_once
      taxonomy_scoped_dummies = @dummy.class.with_taxonomy_scope(@loc, @org)
      assert_empty taxonomy_scoped_dummies
    end

    test 'returns only objects in the given taxonomies' do
      @dummy.name = 'foo'
      @dummy.save
      TaxonomixDummy.expects(:taxable_ids).returns([@dummy.id]).at_least_once
      taxonomy_scoped_dummies = @dummy.class.with_taxonomy_scope(@loc, @org)
      assert_equal 1, taxonomy_scoped_dummies.count
      assert_equal [@dummy], taxonomy_scoped_dummies.to_a
    end

    test 'does not return objects outside the specified taxonomies' do
      @dummy.name = 'foo'
      @dummy.save
      other_ids = TaxonomixDummy.pluck(:id) - [@dummy.id]
      TaxonomixDummy.expects(:taxable_ids).returns(other_ids).at_least_once
      taxonomy_scoped_dummies = @dummy.class.with_taxonomy_scope(@loc, @org)
      assert_equal other_ids.count, taxonomy_scoped_dummies.count
      refute_includes taxonomy_scoped_dummies.to_a, @dummy
    end
  end

  describe '.taxonomy_join_scope' do
    setup do
      @org = FactoryBot.create(:organization)
      @loc = FactoryBot.create(:location)
      @user = FactoryBot.create(:user, :organizations => [@org],
                                :locations => [@loc])
    end

    test 'should not return objects when not in the specified taxonomies' do
      as_admin do
        Organization.current = @org
        Location.current = @loc
        taxonomy_scoped_dummies = @dummy.class.taxonomy_join_scope.all
        assert_equal 0, taxonomy_scoped_dummies.count
      end
    end

    test 'should return all objects for admin' do
      as_admin do
        taxonomy_scoped_dummies = @dummy.class.taxonomy_join_scope.all
        all_dummies = @dummy.class.unscoped.all.to_a.sort
        assert_equal all_dummies, taxonomy_scoped_dummies.to_a.sort
      end
    end

    test 'should return objects for not admin user' do
      envs = []
      3.times do
        envs << FactoryBot.create(:environment, :organizations => [@org], :locations => [@loc])
      end

      assert_equal 3, envs.size

      as_user(@user) do
        environment_scope = Environment.taxonomy_join_scope.all
        refute User.current.admin?
        assert_equal envs.sort, environment_scope.to_a.sort
      end
    end
  end

  test ".used_location_ids can work with array of locations" do
    loc1 = FactoryBot.create(:location)
    loc2 = FactoryBot.create(:location, :parent_id => loc1.id)
    loc3 = FactoryBot.create(:location, :parent_id => loc2.id)
    loc4 = FactoryBot.create(:location)
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
    org1 = FactoryBot.create(:organization)
    org2 = FactoryBot.create(:organization, :parent_id => org1.id)
    org3 = FactoryBot.create(:organization, :parent_id => org2.id)
    org4 = FactoryBot.create(:organization)
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

  describe '#taxable_ids' do
    test "can work with empty array returning nil" do
      assert_nil @dummy.class.taxable_ids([], [])
    end

    test 'returns IDs for non-admin user of any context when no org/loc' do
      assert @dummy.class.all.count > 1

      as_user(:one) do
        any_org = User.current.organizations
        any_loc = User.current.locations

        visible_dummies = any_org.map(&:"#{@dummy.class.table_name}").flatten.map(&:id) &
          any_loc.map(&:"#{@dummy.class.table_name}").flatten.map(&:id)

        # We need to call '.taxable_ids' using the Environment class because
        # '.taxable_ids' will look for the 'taxable_taxonomies.taxable_type'
        # table of the caller.
        # Since TaxonomixDummy is defined in terms of the Environment table,
        # the table will have Environment, not TaxonomixDummy as taxable_type
        assert_equal visible_dummies, Environment.taxable_ids(nil, nil)
        assert_equal visible_dummies, Environment.taxable_ids([], [])
      end
    end

    test 'list only users from the organization and myself but not global admins' do
      loc = FactoryBot.create(:location)
      org = FactoryBot.create(:organization)
      user1 = FactoryBot.create(:user, :organizations => [org], :locations => [loc])
      user2 = FactoryBot.create(:user, :organizations => [org], :locations => [loc])
      admin = FactoryBot.create(:user, :admin)

      as_user(user1) do
        found_ids = User.taxable_ids(loc, org)
        assert_includes found_ids, user1.id
        assert_includes found_ids, user2.id
        refute_includes found_ids, admin.id
      end
    end

    test "can work with array of taxonomies" do
      loc1 = FactoryBot.create(:location)
      loc2 = FactoryBot.create(:location, :parent_id => loc1.id)
      loc3 = FactoryBot.create(:location, :parent_id => loc2.id)
      loc4 = FactoryBot.create(:location)
      org = FactoryBot.create(:organization)
      env1 = FactoryBot.create(:environment, :organizations => [org], :locations => [loc2])
      env2 = FactoryBot.create(:environment, :organizations => [org])
      env3 = FactoryBot.create(:environment, :locations => [loc2])
      env4 = FactoryBot.create(:environment, :locations => [loc4])
      env5 = FactoryBot.create(:environment, :locations => [loc1])
      env6 = FactoryBot.create(:environment, :locations => [loc3])
      taxable_ids = Environment.taxable_ids([loc2, loc4], org, :subtree_ids)
      visible = [env1]
      invisible = [env2, env3, env4, env5, env6]
      visible.each { |env| assert_includes taxable_ids, env.id }
      invisible.each { |env| refute_includes taxable_ids, env.id }

      taxable_ids = Environment.taxable_ids([], org, :subtree_ids)
      visible = [env1, env2]
      invisible = [env3, env4, env5, env6]
      visible.each { |env| assert_includes taxable_ids, env.id }
      invisible.each { |env| refute_includes taxable_ids, env.id }

      taxable_ids = Environment.taxable_ids(loc2, [], :subtree_ids)
      visible = [env1, env3, env5, env6]
      invisible = [env2, env4]
      visible.each { |env| assert_includes taxable_ids, env.id }
      invisible.each { |env| refute_includes taxable_ids, env.id }

      taxable_ids = Environment.taxable_ids([loc2, loc4], [], :subtree_ids)
      visible = [env1, env3, env4, env5, env6]
      invisible = [env2]
      visible.each { |env| assert_includes taxable_ids, env.id }
      invisible.each { |env| refute_includes taxable_ids, env.id }
    end
  end

  test "validation does not prevent taxonomy association if user does not have permissions of already assigned taxonomies" do
    filter = FactoryBot.create(:filter, :search => 'name ~ visible*')
    filter.permissions = Permission.where(:name => ['view_organizations', 'assign_organizations'])
    role = FactoryBot.create(:role)
    role.filters = [filter]

    filter2 = FactoryBot.create(:filter)
    filter2.permissions = Permission.where(:name => ['edit_domains'])
    role2 = FactoryBot.create(:role)
    role2.filters = [filter2]

    user = FactoryBot.create(:user)
    user.roles = [role, role2]
    org1 = FactoryBot.create :organization, :name => 'visible1'
    org2 = FactoryBot.create :organization, :name => 'visible2'
    org3 = FactoryBot.create :organization, :name => 'hidden'
    user.organizations = [org1]

    resource = FactoryBot.create(:domain, :organizations => [org1, org3])
    assert_includes resource.organizations, org3

    as_user user do
      resource.organization_ids = [org1, org2, org3].map(&:id)
      assert resource.save!
    end

    assert_includes resource.organizations, org1
    assert_includes resource.organizations, org2
    assert_includes resource.organizations, org3
  end

  test "default scope does not set create scope attributes" do
    org = FactoryBot.create :organization
    FactoryBot.create(:domain, :organizations => [org])
    original_org, Organization.current = Organization.current, org
    new_dom = Domain.new(:organization_ids => [org.id])
    Organization.current = original_org
    _(new_dom.taxable_taxonomies).must_be :present?
    assert new_dom.taxable_taxonomies.all?(&:valid?)
  end

  test "#taxable_ids works even if the resources uses eager loading on through associations" do
    user = FactoryBot.create(:user)
    filter = FactoryBot.create(:filter)
    filter.permissions = Permission.where(:name => ['view_provisioning_templates'])
    role = FactoryBot.create(:role, :filters => [filter])

    user = FactoryBot.create(:user)
    user.roles = [role]
    org = FactoryBot.create :organization, :ignore_types => ['Hostgroup']
    user.organizations = [org]

    in_taxonomy org do
      as_user user do
        assert_nothing_raised do
          ProvisioningTemplate.includes([:template_combinations => [:hostgroup, :environment]]).search_for('something').first
        end
      end
    end
  end

  test "#admin_ids finds admins both assigned the permission directly and through user group" do
    direct_admin = group_admin = nil
    as_admin do
      direct_admin = FactoryBot.create(:user, :admin)
      group = FactoryBot.create(:usergroup, :admin => true)
      group_admin = FactoryBot.create(:user, :usergroups => [group])
    end

    found_admins = User.admin_ids
    assert_includes found_admins, direct_admin.id
    assert_includes found_admins, group_admin.id
  end

  test "#used_organization_ids should not return organization for user with same id as of user_group which is assigned to host as owner." do
    org = FactoryBot.create(:organization)
    user = FactoryBot.create(:user, :id => 25, :organizations => [org])
    ugroup = FactoryBot.create(:usergroup, :id => 25)
    FactoryBot.create(:host, :owner => ugroup, :organization => org)
    as_admin do
      used_organizations = user.used_organization_ids
      assert_empty used_organizations
      assert_equal used_organizations.count, 0
    end
  end

  context 'admin permissions' do
    test "returns only visible objects when org/loc are selected" do
      scoped_environments = Environment.
        with_taxonomy_scope([taxonomies(:organization1)])
      assert scoped_environments.include?(*taxonomies(:organization1).environments)
      assert_not_equal Environment.unscoped.all, scoped_environments
      assert_equal taxonomies(:organization1).environments, scoped_environments
    end

    test "returns nil (all objects) when there are no org/loc" do
      assert_equal User.with_taxonomy_scope([], []).sort, User.unscoped.all.sort
    end
  end

  test 'current user ID and admin IDs are always visible' do
    as_user(:one) do
      scoped_users = User.with_taxonomy_scope([], [])
      assert_include scoped_users, User.current
    end
  end

  context 'user with objects outside its current taxonomies' do
    setup do
      # Environment in organization 1 and location 1 cannot be seen by an user
      # who is scoped to organization 1 and location 2
      users(:one).organizations = [taxonomies(:organization1)]
      users(:one).locations = [taxonomies(:location2)]
      @unreachable_env = FactoryBot.create(
        :environment,
        :organizations => [taxonomies(:organization1)],
        :locations => [taxonomies(:location1)])
    end

    test 'via resource default scope' do
      as_user(:one) do
        assert_not_include Environment.all, @unreachable_env
      end
    end

    context 'via resource association' do
      setup do
        @hg = FactoryBot.create(:hostgroup, environment: @unreachable_env, locations: [taxonomies(:location2)], organizations: [taxonomies(:organization1)])
        # factory corrected environment taxonomy - put it outside of user one
        @unreachable_env.organizations = [taxonomies(:organization1)]
        @unreachable_env.locations = [taxonomies(:location1)]
      end

      test 'via resource association with no reachable environments' do
        as_user(:one) do
          assert_empty Environment.all, "User should not see any environments for this test"
          hg = Hostgroup.find(@hg.id)
          refute hg.environment
          assert_equal @unreachable_env.id, hg.environment_id
        end
      end

      test 'via resource association with other reachable environments' do
        # Create a reachable environment too, as scope_by_taxable_ids has a separate code path when
        # one or more resources are visible to the user
        FactoryBot.create(:environment,
          :organizations => [taxonomies(:organization1)],
          :locations => [taxonomies(:location2)])

        as_user(:one) do
          hg = Hostgroup.find(@hg.id)
          refute hg.environment
          assert_equal @unreachable_env.id, hg.environment_id
        end
      end
    end
  end
end
