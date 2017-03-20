require 'test_helper'

class Api::V2::MediaControllerTest < ActionController::TestCase
  new_medium = {
    :name => "new medium",
    :path => "http://www.newmedium.com/"
  }

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:media)
    medium = ActiveSupport::JSON.decode(@response.body)
    assert !medium.empty?
  end

  test "should show medium" do
    get :show, params: { :id => media(:one).to_param }
    assert_not_nil assigns(:medium)
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create medium" do
    assert_difference('Medium.unscoped.count', +1) do
      post :create, params: { :medium => new_medium }
    end
    assert_response :created
    assert_not_nil assigns(:medium)
  end

  test "should update medium" do
    name = Medium.first.name
    put :update, params: { :id => Medium.first.id.to_param, :name => name.to_s.to_param }
    assert_response :success
  end

  test "should destroy medium" do
    assert_difference('Medium.unscoped.count', -1) do
      delete :destroy, params: { :id => media(:unused).id.to_param }
    end
    assert_response :success
  end
end
