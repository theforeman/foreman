require 'test_helper'

class HostgroupsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:records)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create hostgroup" do
    assert_difference('Hostgroup.count') do
      post :create, { :commit => "Create", :record => { :name => "my_hostgroup" } }
    end

    assert_redirected_to hostgroups_path
  end

   test "should show hostgroup" do
    hostgroup = Hostgroup.create :name => "my_hostgroup"
    assert hostgroup.save!

    get :show, :id => hostgroup.id
    assert_response :success
   end

  test "should get edit" do
    hostgroup = Hostgroup.create :name => "my_hostgroup"
    assert hostgroup.save!
    get :edit, :id => hostgroup.id
    assert_response :success
  end

  test "should update hostgroup" do
    hostgroup = Hostgroup.create :name => "my_hostgroup"
    assert hostgroup.save!

    put :update, { :commit => "Update", :id => hostgroup.id, :record => {:name => "our_hostgroup"} }
    hostgroup = Hostgroup.find_by_id(hostgroup.id)
    assert hostgroup.name == "our_hostgroup"

    assert_redirected_to hostgroups_path
  end

  test "should destroy hostgroup" do
    hostgroup = Hostgroup.create :name => "my_hostgroup"
    assert hostgroup.save!
    assert_difference('Hostgroup.count', -1) do
      delete :destroy, :id => hostgroup.id
    end

    assert_redirected_to hostgroups_path
  end
end

