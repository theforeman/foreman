require 'test_helper'

class Api::V2::UsergroupsControllerTest < ActionController::TestCase
  def setup
    as_admin { @usergroup = FactoryBot.create(:usergroup) }
  end

  valid_attrs = { :name => 'test_usergroup' }

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:usergroups)
    usergroups = ActiveSupport::JSON.decode(@response.body)
    assert !usergroups.empty?
  end

  test "should show individual record" do
    get :show, params: { :id => @usergroup.to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create usergroup" do
    assert_difference('Usergroup.count') do
      post :create, params: { :usergroup => valid_attrs }
    end
    assert_response :created
  end

  test "should update usergroup" do
    put :update, params: { :id => @usergroup.to_param, :usergroup => valid_attrs }
    assert_response :success
  end

  test "should destroy usergroups" do
    assert_difference('Usergroup.count', -1) do
      delete :destroy, params: { :id => @usergroup.to_param }
    end
    assert_response :success
  end
end
