require 'test_helper'

class Api::V2::JsonWebTokensControllerTest < ActionController::TestCase
  def setup
    @user = FactoryBot.create(:user, admin: false)
  end

  #
  # Generate token tests
  #

  test "admin generate for self" do
    as_user(:admin) { post :create, params: { id: users(:admin).id } }
    assert_response :success
  end

  test "admin generate for user" do
    as_user(:admin) { post :create, params: { id: users(:one).id } }
    assert_response :success
  end

  test "non-admin with permissions generate for self" do
    setup_user('manage', 'json_web_tokens', nil, @user)

    post :create, params: { id: @user.id }
    assert_response :success
  end

  test "non-admin without permissions generate for self" do
    as_user(@user) { post :create, params: { id: @user.id } }
    assert_response :success
  end

  test "non-admin with permissions generate for user" do
    setup_user('edit', 'users', nil, @user)
    setup_user('manage', 'json_web_tokens', nil, @user)

    post :create, params: { id: @user.id }
    assert_response :success
  end

  test "non-admin without `manage_json_web_tokens` generate for user" do
    setup_user('edit', 'users', nil, @user)

    post :create, params: { id: users(:two).id }
    assert_response :forbidden
  end

  test "non-admin without `edit_users` generate for user" do
    setup_user('manage', 'json_web_tokens', nil, @user)

    post :create, params: { id: users(:two).id }
    assert_response :not_found
  end

  #
  # Invalidate tokens tests
  #

  test "admin invalidate for self" do
    as_user(:admin) { delete :destroy, params: { id: @user.id } }
    assert_response :success
  end

  test "admin invalidate for user" do
    as_user(:admin) { delete :destroy, params: { id: @user.id } }
    assert_response :success
  end

  test "non-admin with permissions invalidate for self" do
    setup_user('manage', 'json_web_tokens', nil, @user)

    delete :destroy, params: { id: @user.id }
    assert_response :success
  end

  test "non-admin without permissions invalidate for self" do
    as_user(@user) { delete :destroy, params: { id: @user.id } }
    assert_response :success
  end

  test "non-admin with permissions invalidate for user" do
    setup_user('manage', 'json_web_tokens', nil, @user)
    setup_user('edit', 'users', nil, @user)

    delete :destroy, params: { id: @user.id }
    assert_response :success
  end

  test "non-admin without `manage_json_web_tokens` invalidate for user" do
    setup_user('edit', 'users', nil, @user)

    delete :destroy, params: { id: users(:two).id }
    assert_response :forbidden
  end

  test "non-admin without `edit_users` invalidate for user" do
    setup_user('manage', 'json_web_tokens', nil, @user)

    delete :destroy, params: { id: users(:two).id }
    assert_response :not_found
  end
end
