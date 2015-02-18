require 'test_helper'

class Api::V2::UsergroupsControllerTest < ActionController::TestCase
  def setup
    as_admin { @usergroup = FactoryGirl.create(:usergroup) }
  end

  valid_attrs = { :name => 'test_usergroup' }

  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:usergroups)
    usergroups = ActiveSupport::JSON.decode(@response.body)
    assert !usergroups.empty?
  end

  test "should show individual record" do
    get :show, { :id => @usergroup.to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create usergroup" do
    assert_difference('Usergroup.count') do
      post :create, { :usergroup => valid_attrs }
    end
    assert_response :success
  end

  test "should update usergroup" do
    put :update, { :id => @usergroup.to_param, :usergroup => { } }
    assert_response :success
  end

  test "should destroy usergroups" do
    assert_difference('Usergroup.count', -1) do
      delete :destroy, { :id => @usergroup.to_param }
    end
    assert_response :success
  end
end
