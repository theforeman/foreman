require 'test_helper'

class Api::V2::RolesControllerTest < ActionController::TestCase
  valid_attrs = { :name => 'staff' }

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:roles)
    roles = ActiveSupport::JSON.decode(@response.body)
    refute roles.empty?
    assert_equal Role.order(:name).pluck(:name), roles['results'].map { |r| r['name'] }
  end

  test "should show individual record" do
    get :show, params: { :id => roles(:manager).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    refute show_response.empty?
  end

  test_attributes :pid => '488a0970-f844-4286-b1eb-dd93005b4580'
  test "should create role" do
    assert_difference('Role.count') do
      post :create, params: { :role => valid_attrs }
    end
    assert_response :created
  end

  test_attributes :pid => 'fe65a691-1b04-4bfe-a24b-adb48feb31d1'
  test "should create role with empty taxonomies" do
    assert_difference('Role.count') do
      post :create, params: { :role => valid_attrs.merge(:organizations => [], :locations => []) }
    end
    assert_response :created
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal 0, response['organizations'].count
    assert_equal 0, response['locations'].count
  end

  test_attributes :pid => '30cb4b42-24cd-48a0-a3c5-7ca44c060e2e'
  test "should update role" do
    put :update, params: { :id => roles(:destroy_hosts).to_param, :role => valid_attrs }
    assert_response :success
  end

  test_attributes :pid => '6e1d9f9c-3cbb-460b-8ef8-4a156e6552a0'
  test "should destroy roles" do
    assert_difference('Role.count', -1) do
      delete :destroy, params: { :id => roles(:destroy_hosts).to_param }
    end
    assert_response :success
  end

  test "should clone role and its permissions" do
    new_name = "New Manager"
    manager = Role.find_by :name => "Manager"
    perm_count = manager.permissions.count
    post :clone, params: { :name => new_name, :id => manager.id }
    assert_response :success
    r = Role.find_by :name => new_name
    assert_equal perm_count, r.permissions.count
  end

  test_attributes :pid => 'b129642d-926d-486a-84d9-5952b44ac446'
  test "should remove role with associated filters" do
    role = FactoryBot.create(:role, :name => "New Role")
    FactoryBot.create(:filter, :role_id => role.id, :permission_ids => [permissions(:view_domains).id])
    assert_difference('Role.count', -1) do
      assert_difference('Filter.count', -1) do
        delete :destroy, params: { :id => role.id }
      end
    end
    assert_response :success
  end

  test_attributes :pid => '31079015-5ede-439a-a062-e20d1ffd66df'
  test "should clone role and its taxonomies" do
    new_name = "New Role"
    loc = Location.first
    org = Organization.first
    role = FactoryBot.create(:role, :name => "Test Role", :locations => [loc], :organizations => [org])
    post :clone, params: { :id => role.id, :role => { :name => new_name } }
    assert_response :success
    r = Role.find_by :name => new_name
    assert_equal 1, r.organizations.count
    assert_equal 1, r.locations.count
    assert_equal org, r.organizations.first
    assert_equal loc, r.locations.first
  end

  test "should override attributes when clonning" do
    new_name = "New Role"
    loc = taxonomies(:location1)
    org = taxonomies(:organization1)
    desc = "default description"
    new_org = taxonomies(:organization2)
    new_loc = taxonomies(:location2)
    new_desc = "updated description"
    new_role = { :description => new_desc, :location_ids => [new_loc.id], :organization_ids => [new_org.id], :name => new_name }
    role = FactoryBot.create(:role, :name => "Test Role", :locations => [loc], :organizations => [org], :description => desc)
    post :clone, params: { :name => new_name,
                           :id => role.id,
                           :role => new_role }
    assert_response :success
    cloned_role = Role.find_by :name => new_name
    assert cloned_role
    assert_equal new_org, cloned_role.organizations.first
    assert_equal new_loc, cloned_role.locations.first
    assert_equal new_desc, cloned_role.description
  end

  test "should override organizations and leave locations alone when clonning" do
    new_name = "New Role"
    loc = taxonomies(:location1)
    org = taxonomies(:organization1)
    desc = "default description"
    new_org = taxonomies(:organization2)
    new_desc = "updated description"
    new_role = { :description => new_desc, :organization_ids => [new_org.id], :name => new_name }
    role = FactoryBot.create(:role, :name => "Test Role", :locations => [loc], :organizations => [org], :description => desc)
    post :clone, params: { :name => new_name,
                           :id => role.id,
                           :role => new_role }
    assert_response :success
    cloned_role = Role.find_by :name => new_name
    assert cloned_role
    assert_equal new_org, cloned_role.organizations.first
    assert_equal loc, cloned_role.locations.first
    assert_equal new_desc, cloned_role.description
  end

  test "should not have any taxonomies when clonning" do
    new_name = "New Role"
    loc = taxonomies(:location1)
    org = taxonomies(:organization1)
    desc = "default description"
    new_role = { :location_ids => [], :organization_ids => [], :name => new_name }
    role = FactoryBot.create(:role, :name => "Test Role", :locations => [loc], :organizations => [org], :description => desc)
    post :clone, params: { :name => new_name,
                           :id => role.id,
                           :role => new_role }
    assert_response :success
    cloned_role = Role.find_by :name => new_name
    assert cloned_role
    assert_equal [], cloned_role.organizations
    assert_equal [], cloned_role.locations
  end

  context "with organization and locations" do
    before do
      @org = taxonomies(:organization1)
      @loc = taxonomies(:location1)
    end

    test_attributes :pid => 'fa449217-889c-429b-89b5-0b6c018ffd9e'
    test "should create role with taxonomies" do
      name = 'Test Role'
      valid_attrs = { :name => name, :location_ids => [@loc.id], :organization_ids => [@org.id] }
      post :create, params: { :role => valid_attrs }
      assert_response :success
      role = Role.find_by :name => name
      assert_equal @org, role.organizations.first
      assert_equal @loc, role.locations.first
    end

    test_attributes :pid => 'bf33b70a-25a9-4eb1-982f-03448d008ec8'
    test "should create org admin role and its permissions" do
      new_name = "Org Admin"
      # Note: org admin role has no default permissions in unit-tests, for real functionality we have to load them before.
      load File.join(Rails.root, '/db/seeds.d/030-permissions.rb')
      load File.join(Rails.root, '/db/seeds.d/040-roles.rb')
      default_org_admin_role = roles(:organization_admin)
      refute_empty default_org_admin_role.permission_names
      new_role = { :name => new_name }
      post :clone, params: { :new_name => new_name,
                             :id => roles(:organization_admin).to_param,
                             :role => new_role }
      assert_response :success
      cloned_org_admin_role = Role.find_by :name => new_name
      assert cloned_org_admin_role
      assert_equal default_org_admin_role.permission_names.sort, cloned_org_admin_role.permission_names.sort
    end

    test_attributes :pid => '03fac76c-22ac-43cf-9068-b96e255b3c3c'
    test "should remove org admin role" do
      default_org_admin = roles(:organization_admin)
      role_name = 'new_org_admin'
      cloned_org_admin = default_org_admin.clone(:name => role_name, :organizations => [@org], :locations => [@loc])
      cloned_org_admin.save!
      org_admin_user = User.create!(
        :login => "foo",
        :mail => "foo@bar.com",
        :auth_source => auth_sources(:one),
        :roles => [cloned_org_admin],
        :organizations => [@org],
        :locations => [@loc]
      )
      assert_difference('Role.count', -1) do
        delete :destroy, params: { :id => cloned_org_admin.id }
      end
      assert_response :success
      org_admin_user.reload
      refute Role.exists?(:id => cloned_org_admin.id)
      refute_includes org_admin_user.roles.map { |role| role.id }, cloned_org_admin.id
    end

    test_attributes :pid => '902dcb32-2126-4ff4-b733-3e86749ccd1e'
    test "should update non-overridable filter taxonomies on role taxonomies update" do
      role_name = 'New Role'
      role = FactoryBot.create(:role, :name => role_name)
      filter = FactoryBot.create(:filter, :role_id => role.id, :permission_ids => [permissions(:view_domains).id])
      new_role_attrs = { :location_ids => [@loc.id], :organization_ids => [@org.id] }
      put :update, params: { :id => role.id, :role => new_role_attrs }
      assert_response :success
      updated_role = Role.find_by :name => role_name
      assert @org, updated_role.organizations.first
      assert @loc, updated_role.locations.first
      updated_filter = Filter.find_by :id => filter.id
      assert_equal @org, updated_filter.organizations.first
      assert_equal @loc, updated_filter.locations.first
    end

    test_attributes :pid => '9f3bf95a-f71a-4063-b51c-12610bc655f2'
    test "should not update overridable filter taxonomies on role taxonomies update" do
      role_name = 'New Role'
      role = FactoryBot.create(:role, :name => role_name)
      filter = FactoryBot.create(:filter, :role_id => role.id, :permission_ids => [permissions(:view_domains).id], :override => true)
      new_role_attrs = { :location_ids => [@loc.id], :organization_ids => [@org.id] }
      put :update, params: { :id => role.id, :role => new_role_attrs }
      assert_response :success
      updated_role = Role.find_by :name => role_name
      assert @org, updated_role.organizations.first
      assert @loc, updated_role.locations.first
      updated_filter = Filter.find_by :id => filter.id
      assert_equal [], updated_filter.organizations
      assert_equal [], updated_filter.locations
    end
  end

  test_attributes :pid => '806ecc16-0dc7-405b-90d3-0584eced27a3'
  test "org admin should not create roles by default" do
    org = taxonomies(:organization1)
    # Note: org admin role has no default permissions in unit-tests, for real functionality we have to load them before.
    load File.join(Rails.root, '/db/seeds.d/030-permissions.rb')
    load File.join(Rails.root, '/db/seeds.d/040-roles.rb')
    default_org_admin_role = Role.find_by_name('Organization admin')
    refute_empty default_org_admin_role.permissions
    org_admin_role = default_org_admin_role.clone(:name => 'new_org_admin', :organizations => [org])
    org_admin_role.save!
    org_admin_user = User.create(
      :login => "foo",
      :mail => "foo@bar.com",
      :auth_source => auth_sources(:one),
      :roles => [org_admin_role],
      :organizations => [org]
    )
    as_user org_admin_user do
      put :create, params: { :role => { :name => 'newrole'} }
    end
    assert_response :forbidden
    response = JSON.parse(@response.body)
    assert_equal "Missing one of the required permissions: create_roles", response['error']['details']
  end
end
