require 'test_helper'

class UserMenusControllerTest < ActionController::TestCase
  test "should show menu items for current user" do
    user = FactoryBot.create(:user, :roles => [roles(:default_role)])
    as_user user do
      get :menu
    end

    assert_response :success
    refute_empty JSON.parse(@response.body)
  end

  test "should need authentication to display menu items" do
    reset_api_credentials
    @request.session[:user] = nil
    @request.session[:expires_at] = nil
    User.current = nil
    get :menu
    setup_users
    assert_response :unauthorized
  end

  test "should return menu items with expected structure" do
    user = FactoryBot.create(:user, :roles => [roles(:view_hosts)])
    get :menu, session: { :expires_at => 5.minutes.from_now.to_i, :user => user.id }
    assert_response :success
    res = JSON.parse(@response.body)
    assert res.is_a?(Array)
    assert res.all? { |item| item.is_a?(Hash) && item['name'] && item['url'] }
  end

  test "should return menu items for anonymous admin" do
    user = users(:anonymous)
    get :menu, session: { :expires_at => 5.minutes.from_now.to_i, :user => user.id }
    assert_response :success
  end
end
