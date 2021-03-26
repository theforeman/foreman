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

  test "should create usergroup" do
    assert_difference('Usergroup.count') do
      post :create, params: { :usergroup => valid_attrs }
    end
    assert_response :created
  end

  test "should create usergroup with role" do
    role = Role.find_by_name('Manager')
    post :create, params: { :usergroup => valid_attrs.clone.update(:role_ids => [role.id])}
    assert_response :created
    assert_equal 1, JSON.parse(@response.body)["roles"].length
    assert_equal role.name, JSON.parse(@response.body)["roles"][0]["name"], "Can't create usergroup with role #{role}"
  end

  test "should create usergroup with roles" do
    roles = [
      Role.find_by_name('Manager'),
      Role.find_by_name('View hosts'),
      Role.find_by_name('Edit hosts'),
    ]
    post :create, params: { :usergroup => valid_attrs.clone.update(:role_ids => roles.map { |role| role.id })}
    assert_response :created
    assert_equal roles.length, JSON.parse(@response.body)["roles"].length
    assert_equal JSON.parse(@response.body)["roles"].map { |role| role["name"] }.sort, roles.map { |role| role.name }.sort, "Can't create usergroup with roles #{roles}"
  end

  test "should create usergroup with user" do
    user = User.find_by_login('one')
    post :create, params: { :usergroup => valid_attrs.clone.update(:user_ids => [user.id])}
    assert_response :created
    assert_equal 1, JSON.parse(@response.body)["users"].length
    assert_equal JSON.parse(@response.body)["users"][0]["login"], user.login, "Can't create usergroup with user #{user}"
  end

  test "should create usergroup with users" do
    users = [
      User.find_by_login('one'),
      User.find_by_login('two'),
      User.find_by_login('test'),
    ]
    post :create, params: { :usergroup => valid_attrs.clone.update(:user_ids => users.map { |user| user.id })}
    assert_response :created
    assert_equal users.length, JSON.parse(@response.body)["users"].length
    assert_equal JSON.parse(@response.body)["users"].map { |user| user["login"] }.sort, users.map { |user| user.login }.sort, "Can't create usergroup with users #{users}"
  end

  test "should create usergroup with usergroup" do
    post :create, params: { :usergroup => valid_attrs.clone.update(:usergroup_ids => [@usergroup.id])}
    assert_response :created
    assert_equal 1, JSON.parse(@response.body)["usergroups"].length
    assert_equal JSON.parse(@response.body)["usergroups"][0]["name"], @usergroup.name, "Can't create usergroup with usergroup #{@usergroup}"
  end

  test "should update usergroup" do
    put :update, params: { :id => @usergroup.to_param, :usergroup => valid_attrs }
    assert_response :success
  end

  test "should update usergroup with role" do
    role = Role.find_by_name('Manager')
    put :update, params: { :id => @usergroup.to_param, :usergroup => valid_attrs.clone.update(:role_ids => [role.id]) }
    assert_response :success
    assert_equal role.name, JSON.parse(@response.body)["roles"][0]["name"], "Can't update usergroup with role #{role}"
  end

  test "should update usergroup with user" do
    user = User.find_by_login('one')
    put :update, params: { :id => @usergroup.to_param, :usergroup => valid_attrs.clone.update(:user_ids => [user.id]) }
    assert_response :success
    assert_equal JSON.parse(@response.body)["users"][0]["login"], user.login, "Can't update usergroup with user #{user}"
  end

  test "should update usergroup with usergroup" do
    usergroup = FactoryBot.create(:usergroup)
    put :update, params: { :id => @usergroup.to_param, :usergroup => valid_attrs.clone.update(:usergroup_ids => [usergroup.id]) }
    assert_response :success
    assert_equal JSON.parse(@response.body)["usergroups"][0]["name"], usergroup.name, "Can't update usergroup with user #{usergroup}"
  end

  test "should not update usergroup with itself" do
    usergroup = FactoryBot.create(:usergroup)
    put :update, params: { :id => usergroup.to_param, :usergroup => {:usergroup_ids => [usergroup.id] } }
    assert_response :unprocessable_entity
    assert_equal "Validation failed: cannot contain itself as member", JSON.parse(@response.body)['error']['errors']['usergroups'].first
  end

  test "should destroy usergroups" do
    assert_difference('Usergroup.count', -1) do
      delete :destroy, params: { :id => @usergroup.to_param }
    end
    assert_response :success
  end

  test "should not create usergroup with invalid name" do
    post :create, params: { :usergroup => { :name => '' } }
    assert_response :unprocessable_entity, "Can create usergroup with empty name"
  end

  test "should not create usergroup with same name" do
    post :create, params: { :usergroup => { :name => @usergroup.name } }
    assert_response :unprocessable_entity, "Can create usergroup with already taken name"
  end

  test "should not update usergroup with invalid name" do
    put :update, params: { :id => @usergroup.id, :usergroup => { :name => '' } }
    assert_response :unprocessable_entity, "Can update usergroup with empty name"
    @usergroup.reload
    assert_not_equal @usergroup.name, ''
  end

  test "should not update usergroup with same name" do
    usergroup = FactoryBot.create(:usergroup)
    put :update, params: { :id => usergroup.id, :usergroup => { :name => @usergroup.name } }
    assert_response :unprocessable_entity, "Can update usergroup with already taken name"
    @usergroup.reload
    assert_not_equal usergroup.name, @usergroup.name
  end

  test 'non-admin user with manager role should not be able to modify the user group when touching the admin flag' do
    usergroup = FactoryBot.create(:usergroup, :admin => false)
    setup_user 'edit', 'usergroups'

    put :update, params: { :id => usergroup.id, :usergroup => { :admin => true } }, session: set_session_user
    assert_response :unprocessable_entity
  end

  test 'non-admin user with manager role should be able to modify the user group without touching the admin flag' do
    usergroup = FactoryBot.create(:usergroup, :admin => false)
    setup_user 'edit', 'usergroups'

    put :update, params: { :id => usergroup.id, :usergroup => { :name => usergroup.name + 'x'} }, session: set_session_user
    assert_response :success
  end

  test 'non-admin user with manager role should not be able to create the user group with the admin flag' do
    setup_user 'create', 'usergroups'
    usergroup = FactoryBot.build(:usergroup)

    post :create, params: { :usergroup => { :name => usergroup.name, :admin => true } }, session: set_session_user
    assert_response :unprocessable_entity
  end

  test 'non-admin user with manager role should be able to create the user group even with the false admin flag' do
    setup_user 'create', 'usergroups'
    usergroup = FactoryBot.build(:usergroup)

    post :create, params: { :usergroup => { :name => usergroup.name, :admin => false } }, session: set_session_user
    assert_response :success
  end

  test 'non-admin user with manager role should be able to create the user group if admin flag is not set' do
    setup_user 'create', 'usergroups'
    usergroup = FactoryBot.build(:usergroup)

    post :create, params: { :usergroup => { :name => usergroup.name } }, session: set_session_user
    assert_response :success
  end
end
