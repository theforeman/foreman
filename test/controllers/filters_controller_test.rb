require 'test_helper'

class FiltersControllerTest < ActionController::TestCase
  setup do
    @model = Filter.first
    User.current = users(:admin)
  end

  basic_index_test('filters')
  basic_pagination_per_page_test
  basic_pagination_rendered_test

  test "changes should expire topbar cache" do
    user1 = FactoryBot.create(:user, :with_mail)
    user2 = FactoryBot.create(:user, :with_mail)
    filter = FactoryBot.create(:filter, :on_name_all)
    role = filter.role
    role.users = [user1, user2]
    role.save!

    User.any_instance.expects(:expire_topbar_cache).twice
    put :update, params: { :id => filter.id, :filter => {:role_id => role.id, :search => "name ~ a*"} }, session: set_session_user
  end

  test "should get index with role_id and create scoped search on role.name" do
    role = roles(:manager)
    get :index, params: { :role_id => role.id }, session: set_session_user
    assert_response :success
    refute_empty assigns(:filters)
    assert_equal Filter.search_for("role = #{role.name}").count, assigns(:filters).count
    assert_match "{&quot;caption&quot;:&quot;Roles&quot;,&quot;url&quot;:&quot;/roles&quot;},{&quot;caption&quot;:&quot;Manager filters&quot;}", @response.body
  end

  test "should destroy filter" do
    assert_difference('Filter.count', -1) do
      delete :destroy, params: {:id => filters(:destroy_hosts_1)}, session: set_session_user
    end
    assert_redirected_to filters_path
  end

  test 'should return data-tables pagination when asked for it' do
    role = roles(:manager)
    get :index, params: { :role_id => role.id, :paginate => 'client' }, session: set_session_user
    assert_response :success
    refute_empty assigns(:filters)

    assert_select "table[data-table='inline']"
  end
end
