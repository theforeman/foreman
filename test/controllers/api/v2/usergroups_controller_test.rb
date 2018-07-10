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

  test_attributes :pid => '3a2255d9-f48d-4f22-a4b9-132361bd9224'
  test "should create usergroup" do
    assert_difference('Usergroup.count') do
      post :create, params: { :usergroup => valid_attrs }
    end
    assert_response :created
  end

  test_attributes :pid => 'c4fac71a-9dda-4e5f-a5df-be362d3cbd52'
  test "should create usergroup with role" do
    role = Role.find_by_name('Manager')
    post :create, params: { :usergroup => valid_attrs.clone.update(:role_ids => [role.id])}
    assert_response :created
    assert_equal 1, JSON.parse(@response.body)["roles"].length
    assert_equal role.name, JSON.parse(@response.body)["roles"][0]["name"], "Can't create usergroup with role #{role}"
  end

  test_attributes :pid => '5838fcfd-e256-49cf-aef8-b2bf215b3586'
  test "should create usergroup with roles" do
    roles = [
      Role.find_by_name('Manager'),
      Role.find_by_name('View hosts'),
      Role.find_by_name('Edit hosts')
    ]
    post :create, params: { :usergroup => valid_attrs.clone.update(:role_ids => roles.map { |role| role.id })}
    assert_response :created
    assert_equal roles.length, JSON.parse(@response.body)["roles"].length
    assert_equal JSON.parse(@response.body)["roles"].map { |role| role["name"] }.sort, roles.map { |role| role.name }.sort, "Can't create usergroup with roles #{roles}"
  end

  test_attributes :pid => 'ab127e09-31d2-4c5b-ae6c-726e4b11a21e'
  test "should create usergroup with user" do
    user = User.find_by_login('one')
    post :create, params: { :usergroup => valid_attrs.clone.update(:user_ids => [user.id])}
    assert_response :created
    assert_equal 1, JSON.parse(@response.body)["users"].length
    assert_equal JSON.parse(@response.body)["users"][0]["login"], user.login, "Can't create usergroup with user #{user}"
  end

  test_attributes :pid => 'b8dbbacd-b5cb-49b1-985d-96df21440652'
  test "should create usergroup with users" do
    users = [
      User.find_by_login('one'),
      User.find_by_login('two'),
      User.find_by_login('test')
    ]
    post :create, params: { :usergroup => valid_attrs.clone.update(:user_ids => users.map { |user| user.id })}
    assert_response :created
    assert_equal users.length, JSON.parse(@response.body)["users"].length
    assert_equal JSON.parse(@response.body)["users"].map { |user| user["login"] }.sort, users.map { |user| user.login }.sort, "Can't create usergroup with users #{users}"
  end

  test_attributes :pid => '2a3f7b1a-7411-4c12-abaf-9a3ca1dfae31'
  test "should create usergroup with usergroup" do
    post :create, params: { :usergroup => valid_attrs.clone.update(:usergroup_ids => [@usergroup.id])}
    assert_response :created
    assert_equal 1, JSON.parse(@response.body)["usergroups"].length
    assert_equal JSON.parse(@response.body)["usergroups"][0]["name"], @usergroup.name, "Can't create usergroup with usergroup #{@usergroup}"
  end

  test_attributes :pid => 'b4f0a19b-9059-4e8b-b245-5a30ec06f9f3'
  test "should update usergroup" do
    put :update, params: { :id => @usergroup.to_param, :usergroup => valid_attrs }
    assert_response :success
  end

  test_attributes :pid => '8e0872c1-ae88-4971-a6fc-cd60127d6663'
  test "should update usergroup with role" do
    role = Role.find_by_name('Manager')
    put :update, params: { :id => @usergroup.to_param, :usergroup => valid_attrs.clone.update(:role_ids => [role.id]) }
    assert_response :success
    assert_equal role.name, JSON.parse(@response.body)["roles"][0]["name"], "Can't update usergroup with role #{role}"
  end

  test_attributes :pid => 'e11b57c3-5f86-4963-9cc6-e10e2f02468b'
  test "should update usergroup with user" do
    user = User.find_by_login('one')
    put :update, params: { :id => @usergroup.to_param, :usergroup => valid_attrs.clone.update(:user_ids => [user.id]) }
    assert_response :success
    assert_equal JSON.parse(@response.body)["users"][0]["login"], user.login, "Can't update usergroup with user #{user}"
  end

  test_attributes :pid => '3cb29d07-5789-4f94-9fd9-a7e494b3c110'
  test "should update usergroup with usergroup" do
    usergroup = FactoryBot.create(:usergroup)
    put :update, params: { :id => @usergroup.to_param, :usergroup => valid_attrs.clone.update(:usergroup_ids => [usergroup.id]) }
    assert_response :success
    assert_equal JSON.parse(@response.body)["usergroups"][0]["name"], usergroup.name, "Can't update usergroup with user #{usergroup}"
  end

  test_attributes :pid => 'c5cfcc4a-9177-47bb-8f19-7a8930eb7ca3'
  test "should destroy usergroups" do
    assert_difference('Usergroup.count', -1) do
      delete :destroy, params: { :id => @usergroup.to_param }
    end
    assert_response :success
  end

  test_attributes :pid => '1a3384dc-5d52-442c-87c8-e38048a61dfa'
  test "should not create usergroup with invalid name" do
    post :create, params: { :usergroup => { :name => '' } }
    assert_response :unprocessable_entity, "Can create usergroup with empty name"
  end

  test_attributes :pid => 'aba0925a-d5ec-4e90-86c6-404b9b6f0179'
  test "should not create usergroup with same name" do
    post :create, params: { :usergroup => { :name => @usergroup.name } }
    assert_response :unprocessable_entity, "Can create usergroup with already taken name"
  end

  test_attributes :pid => '03772bd0-0d52-498d-8259-5c8a87e08344'
  test "should not update usergroup with invalid name" do
    put :update, params: { :id => @usergroup.id, :usergroup => { :name => '' } }
    assert_response :unprocessable_entity, "Can update usergroup with empty name"
    @usergroup.reload
    assert_not_equal @usergroup.name, ''
  end

  test_attributes :pid => '14888998-9282-4d81-9e99-234d19706783'
  test "should not update usergroup with same name" do
    usergroup = FactoryBot.create(:usergroup)
    put :update, params: { :id => usergroup.id, :usergroup => { :name => @usergroup.name } }
    assert_response :unprocessable_entity, "Can update usergroup with already taken name"
    @usergroup.reload
    assert_not_equal usergroup.name, @usergroup.name
  end
end
