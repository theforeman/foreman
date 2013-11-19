require 'test_helper'

class Api::V2::SystemGroupsControllerTest < ActionController::TestCase

  valid_attrs = { :name => 'TestSystemGroup' }

  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:system_groups)
    system_groups = ActiveSupport::JSON.decode(@response.body)
    assert !system_groups.empty?
  end

  test "should show individual record" do
    get :show, { :id => system_groups(:common).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create system_group" do
    assert_difference('SystemGroup.count') do
      post :create, { :system_group => valid_attrs }
    end
    assert_response :success
  end

  test "should update system_group" do
    put :update, { :id => system_groups(:common).to_param, :system_group => { } }
    assert_response :success
  end

  test "should destroy system_groups" do
    assert_difference('SystemGroup.count', -1) do
      delete :destroy, { :id => system_groups(:common).to_param }
    end
    assert_response :success
  end

  test "should create nested system_group with a parent" do
    assert_difference('SystemGroup.count') do
      post :create, { :system_group => valid_attrs.merge(:parent_id => system_groups(:common).id) }
    end
    assert_response :success
    assert_equal system_groups(:common).id.to_s, SystemGroup.unscoped.order(:id).last.ancestry
  end

  test "should update a system_group to nested by passing parent_id" do
    put :update, { :id => system_groups(:db).to_param, :system_group => {:parent_id => system_groups(:common).id} }
    assert_response :success
    assert_equal system_groups(:common).id.to_s, SystemGroup.find_by_name("db").ancestry
  end

end
