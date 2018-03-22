require 'test_helper'

class Api::V2::RolesControllerTest < ActionController::TestCase
  valid_attrs = { :name => 'staff' }

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:roles)
    roles = ActiveSupport::JSON.decode(@response.body)
    assert !roles.empty?
    assert_equal Role.order(:name).pluck(:name), roles['results'].map { |r| r['name'] }
  end

  test "should show individual record" do
    get :show, params: { :id => roles(:manager).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create role" do
    assert_difference('Role.count') do
      post :create, params: { :role => valid_attrs }
    end
    assert_response :created
  end

  test "should update role" do
    put :update, params: { :id => roles(:destroy_hosts).to_param, :role => valid_attrs }
    assert_response :success
  end

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
    post :clone, params: { :name => "New Manager", :id => manager.id }
    assert_response :success
    r = Role.find_by :name => new_name
    assert_equal perm_count, r.permissions.count
  end

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
    post :clone, params: { :new_name => new_name,
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
    post :clone, params: { :new_name => new_name,
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
    post :clone, params: { :new_name => new_name,
                           :id => role.id,
                           :role => new_role }
    assert_response :success
    cloned_role = Role.find_by :name => new_name
    assert cloned_role
    assert_equal [], cloned_role.organizations
    assert_equal [], cloned_role.locations
  end
end
