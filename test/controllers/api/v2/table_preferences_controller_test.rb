require 'test_helper'

class Api::V2::TablePreferencesControllerTest < ActionController::TestCase
  def resources
    ["test_subscriptions_resource", "test_organizations_resource"]
  end

  def expected_columns
    ["1", "2", "3"]
  end

  def setup
    setup_users
  end

  def test_should_NOT_get_index_with_json_result
    other_user = FactoryBot.create(:user, :with_widget)
    get :index, params: {user_id: other_user.id}
    assert_response :forbidden
  end

  def test_should_get_index_with_json_result
    get :index, params: {user_id: User.current.id}
    assert_response :success
    columns = ActiveSupport::JSON.decode(@response.body)["results"]
    assert_equal(columns.length, 0)
  end

  def test_should_show_columns_correctly
    resource = resources.first
    TablePreference.create!(user: User.current,
                       name: resource, columns: expected_columns)
    get :show, params: {user_id: User.current.id, id: resource}
    assert_response :success
    actual_columns = ActiveSupport::JSON.decode(@response.body)["columns"]
    assert_equal(expected_columns, actual_columns)
  end

  def test_should_create_correctly
    resource = resources.first
    current_user = User.current
    post :create, params: {user_id: User.current.id, name: resource, columns: expected_columns}
    assert_response :success
    columns = current_user.reload.table_preferences.first
    assert_equal(expected_columns, columns.columns)
  end

  def test_should_update_correctly
    resource = resources.first
    current_user = User.current
    TablePreference.create!(user: User.current,
                       name: resource, columns: expected_columns)

    put :update, params: {user_id: User.current.id, id: resource, columns: expected_columns}
    assert_response :success
    columns = current_user.reload.table_preferences.first
    assert_equal(expected_columns, columns.columns)
  end

  def test_should_destroy_correctly
    resource1 = resources[0]
    resource2 = resources[1]
    current_user = User.current
    TablePreference.create!(user: User.current,
                       name: resource1, columns: expected_columns)
    TablePreference.create!(user: User.current,
                       name: resource2, columns: expected_columns)

    delete :destroy, params: { user_id: User.current.id, id: resource1}
    assert_response :success

    columns = current_user.reload.table_preferences
    assert_equal(1, columns.size)
    assert_equal(resource2, columns.first.name)
  end

  def test_should_get_index_non_admin_user
    setup_user 'view', 'table_preferences'
    get :index, params: {user_id: User.current.id}
    assert_response :success
    columns = ActiveSupport::JSON.decode(@response.body)["results"]
    assert_equal(columns.length, 0)
  end
end
