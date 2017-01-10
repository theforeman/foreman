require 'test_helper'

class FiltersControllerTest < ActionController::TestCase
  setup do
    @model = Filter.first
    User.current = users(:admin)
  end

  basic_index_test('filters')
  basic_new_test
  basic_edit_test('filter')

  test "changes should expire topbar cache" do
    user1 = FactoryGirl.create(:user, :with_mail)
    user2 = FactoryGirl.create(:user, :with_mail)
    filter = FactoryGirl.create(:filter, :on_name_all)
    role = filter.role
    role.users = [user1, user2]
    role.save!

    User.any_instance.expects(:expire_topbar_cache).twice
    put :update, { :id => filter.id, :filter => {:role_id => role.id, :search => "name ~ a*"}}, set_session_user
  end

  test "should get index with role_id and create scoped search on role.name" do
    role = roles(:manager)
    get :index, {:role_id => role.id}, set_session_user
    assert_response :success
    refute_empty assigns(:filters)
    assert_equal Filter.search_for("role = #{role.name}").count, assigns(:filters).count
    assert_match "Filters for role Manager", @response.body
  end

  test "should create filter" do
    assert_difference('Filter.count') do
      post :create, {:filter => { :role_id => roles(:destroy_hosts).id, :permission_ids => [permissions(:access_dashboard).id] }}, set_session_user
    end
    assert_redirected_to filters_path
  end

  test "should update filter" do
    put :update, {:id => filters(:destroy_hosts_1), :filter => { :permission_ids => [permissions(:access_dashboard).id] }}, set_session_user
    assert_redirected_to filters_path
  end

  test "should destroy filter" do
    assert_difference('Filter.count', -1) do
      delete :destroy, {:id => filters(:destroy_hosts_1)}, set_session_user
    end
    assert_redirected_to filters_path
  end

  test 'should return server pagination controls by default' do
    role = roles(:manager)
    get :index, {:role_id => role.id}, set_session_user
    assert_response :success
    refute_empty assigns(:filters)

    pagination_line = css_select('div.pagination').first
    assert_match "Displaying", pagination_line.children.first.content
  end

  test 'should return data-tables pagination when asked for it' do
    role = roles(:manager)
    get :index, {:role_id => role.id, :paginate => 'client'}, set_session_user
    assert_response :success
    refute_empty assigns(:filters)

    assert_select "table[data-table='inline']"
  end

  test 'should disable overriding and start inheriting taxonomies from roles' do
    permission1 = FactoryGirl.create(:permission, :domain, :name => 'permission1')
    role = FactoryGirl.build(:role, :permissions => [])
    role.add_permissions! [permission1.name]
    org1 = FactoryGirl.create(:organization)
    org2 = FactoryGirl.create(:organization)
    role.organizations = [ org1 ]
    role.filters.reload
    filter_with_org = role.filters.detect(&:allows_organization_filtering?)
    filter_with_org.update_attributes :organizations => [ org1, org2 ], :override => true

    patch :disable_overriding, { :role_id => role.id, :id => filter_with_org.id }, set_session_user

    assert_response :redirect
    filter_with_org.reload
    assert_equal [ org1 ], filter_with_org.organizations
    refute filter_with_org.override
  end
end
