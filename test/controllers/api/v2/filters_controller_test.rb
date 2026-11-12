require 'test_helper'

class Api::V2::FiltersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:filters)
    filters = ActiveSupport::JSON.decode(@response.body)
    assert !filters.empty?
  end

  test "should show individual record" do
    get :show, params: { :id => filters(:manager_1).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should list filters regardless of the user's filter permission search" do
    allowed_role = FactoryBot.create(:role)
    user = user_with_filter_permission(allowed_role, :view_filters)
    target_filter = FactoryBot.create(
      :filter,
      :role => FactoryBot.create(:role),
      :permissions => [permissions(:view_hosts)]
    )

    as_user user do
      get :index, params: { :per_page => 'all' }, session: set_session_user(user)

      assert_response :success
      assert_includes @response.body, %("id":#{target_filter.id})
    end
  end

  test "should show filters regardless of the user's filter permission search" do
    allowed_role = FactoryBot.create(:role)
    user = user_with_filter_permission(allowed_role, :view_filters)
    target_filter = FactoryBot.create(
      :filter,
      :role => FactoryBot.create(:role),
      :permissions => [permissions(:view_hosts)]
    )

    as_user user do
      get :show, params: { :id => target_filter.to_param }, session: set_session_user(user)

      assert_response :success
      assert_includes @response.body, %("id":#{target_filter.id})
    end
  end

  test_attributes :pid => 'b8631d0a-a71a-41aa-9f9a-d12d62adc496'
  test "should create filter" do
    valid_attrs = { :role_id => roles(:destroy_hosts).id, :permission_ids => [permissions(:view_architectures).id] }
    assert_difference('Filter.count') do
      post :create, params: { :filter => valid_attrs }
    end
    assert_response :created
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_equal show_response["permissions"].first["name"], "view_architectures"
  end

  test "should create filter with scoped organization" do
    role = FactoryBot.create(:role, :organization_ids => [taxonomies(:organization1).id], :name => "role_test")

    filter = { :role_id => role.id, :permission_ids => [permissions(:view_architectures).id]}
    assert_difference('Filter.count') do
      post :create, params: { :filter => filter, :organization_id => taxonomies(:organization1).id}
    end
    assert_response :created
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_equal show_response["permissions"].first["name"], "view_architectures"
  end

  test "should update filter" do
    valid_attrs = { :role_id => roles(:destroy_hosts).id, :permission_ids => [permissions(:create_hosts).id] }
    put :update, params: { :id => filters(:destroy_hosts_1).to_param, :filter => valid_attrs }
    assert_response :success
  end

  test_attributes :pid => 'f0c56fd8-c91d-48c3-ad21-f538313b17eb'
  test "should destroy filters" do
    assert_difference('Filter.count', -1) do
      delete :destroy, params: { :id => filters(:destroy_hosts_1).to_param }
    end
    assert_response :success
  end

  test "should destroy a filter within a search-limited destroy permission" do
    allowed_role = FactoryBot.create(:role)
    user = user_with_filter_permission(allowed_role, :destroy_filters)
    target_filter = FactoryBot.create(
      :filter,
      :role => allowed_role,
      :permissions => [permissions(:view_hosts)]
    )

    as_user user do
      assert_difference('Filter.count', -1) do
        delete :destroy, params: { :id => target_filter.to_param }, session: set_session_user(user)
      end
      assert_response :success
    end
    assert_not Filter.exists?(target_filter.id)
  end

  test "should not destroy a filter outside of a search-limited destroy permission" do
    allowed_role = FactoryBot.create(:role)
    user = user_with_filter_permission(allowed_role, :destroy_filters)
    target_filter = FactoryBot.create(
      :filter,
      :role => FactoryBot.create(:role),
      :permissions => [permissions(:view_hosts)]
    )

    as_user user do
      assert_no_difference('Filter.count') do
        delete :destroy, params: { :id => target_filter.to_param }, session: set_session_user(user)
      end
      assert_response :not_found
    end
    assert Filter.exists?(target_filter.id)
  end

  test "should update a filter within a search-limited edit permission" do
    allowed_role = FactoryBot.create(:role)
    user = user_with_filter_permission(allowed_role, :edit_filters)
    filter = FactoryBot.create(
      :filter,
      :role => allowed_role,
      :permissions => [permissions(:view_hosts)]
    )

    as_user user do
      put :update,
        params: { :id => filter.to_param, :filter => { :role_id => allowed_role.id, :search => 'name = updated' } },
        session: set_session_user(user)

      assert_response :success
    end
    assert_equal 'name = updated', filter.reload.search
  end

  test "should not update a filter outside of a search-limited edit permission" do
    allowed_role = FactoryBot.create(:role)
    user = user_with_filter_permission(allowed_role, :edit_filters)
    target_role = FactoryBot.create(:role)
    filter = FactoryBot.create(
      :filter,
      :role => target_role,
      :permissions => [permissions(:view_hosts)]
    )

    as_user user do
      put :update,
        params: { :id => filter.to_param, :filter => { :role_id => allowed_role.id, :search => 'name = moved' } },
        session: set_session_user(user)

      assert_response :not_found
    end
    assert_equal target_role.id, filter.reload.role_id
    assert_nil filter.search
  end

  private

  def user_with_filter_permission(role, permission)
    Permission.find_or_create_by!(:name => permission.to_s, :resource_type => 'Filter')
    role.add_permissions!(permission, :search => "role_id = #{role.id}")
    FactoryBot.create(:user, :admin => false, :roles => [role])
  end
end
