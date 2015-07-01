require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  test 'should get index' do
    get :index, {}, set_session_user
    assert_response :success
  end

  test 'create returns 404 if widget to add is not found' do
    post :create, { :name => 'non-existent-widget' }, set_session_user
    assert_response :not_found
  end

  test 'create adds widget to user if widget is valid' do
    assert_difference('users(:admin).widgets.count', 1) do
      post :create, { :name => 'Status table' }, set_session_user
    end
    assert_response :success
  end
end
