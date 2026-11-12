require 'test_helper'

class Api::V2::SshKeysControllerTest < ActionController::TestCase
  valid_attrs = {
    :name => 'foreman@example.com',
    :key => 'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBIhRoL6PfBRs9YwW3r2/pYeLrxRzEZSUO3Go8JivxMsguEKjJ3byHDPvPpMHhKKSZD/HJY/A+2Ndqp0ElB+t2qs= foreman@example.com',
  }

  def setup
    @user = FactoryBot.create(:user)
    @ssh_key = FactoryBot.create(:ssh_key, :user => @user)
    FactoryBot.create(:permission, :name => 'create_ssh_keys', :resource_type => 'SshKey')
  end

  test "should get index" do
    get :index, params: { :user_id => @user.id }
    assert_response :success
    assert_not_nil assigns(:ssh_keys)
    ssh_keys = ActiveSupport::JSON.decode(@response.body)
    assert !ssh_keys.empty?
  end

  test "should show individual record" do
    get :show, params: { :id => @ssh_key.to_param, :user_id => @user.id }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create ssh_key" do
    assert_difference('SshKey.count') do
      post :create, params: { :ssh_key => valid_attrs, :user_id => @user.id }
    end
    assert_response :created
  end

  test "should created ssh_key with unwrapped 'layout'" do
    assert_difference('SshKey.count') do
      post :create, params: valid_attrs.merge(:user_id => @user.id)
    end
    assert_response :created
  end

  test "should destroy ssh_key" do
    assert_difference('SshKey.count', -1) do
      delete :destroy, params: { :id => @ssh_key.to_param, :user_id => @user.id }
    end
    assert_response :success
  end

  context 'with non-admin user' do
    it 'allows creating an SSH key for itself without create permission' do
      caller = FactoryBot.create(:user)

      assert_difference('SshKey.count') do
        post :create, params: { :ssh_key => valid_attrs, :user_id => caller.id }, session: set_session_user(caller)
      end

      assert_response :created
      assert_equal caller, assigns(:ssh_key).user
    end

    it 'does not create an SSH key for a user it cannot edit' do
      caller = FactoryBot.create(:user)
      setup_user('create', 'ssh_keys', nil, caller)

      assert_no_difference('SshKey.count') do
        post :create, params: { :ssh_key => valid_attrs, :user_id => @user.id }, session: set_session_user(caller)
      end

      assert_response :not_found
    end

    it 'does not create an SSH key for another user without create permission' do
      caller = FactoryBot.create(:user)
      setup_user('edit', 'users', nil, caller)

      assert_no_difference('SshKey.count') do
        post :create, params: { :ssh_key => valid_attrs, :user_id => @user.id }, session: set_session_user(caller)
      end

      assert_response :forbidden
    end

    it 'creates an SSH key for a user it can edit with create permission' do
      caller = FactoryBot.create(:user)
      setup_user('create', 'ssh_keys', nil, caller)
      setup_user('edit', 'users', nil, caller)

      assert_difference('SshKey.count') do
        post :create, params: { :ssh_key => valid_attrs, :user_id => @user.id }, session: set_session_user(caller)
      end

      assert_response :created
      assert_equal @user, assigns(:ssh_key).user
    end

    it 'creates an SSH key for a user in its edit_users filter' do
      caller = FactoryBot.create(:user)
      setup_user('create', 'ssh_keys', nil, caller)
      setup_user('edit', 'users', "id = #{@user.id}", caller)

      assert_difference('SshKey.count') do
        post :create, params: { :ssh_key => valid_attrs, :user_id => @user.id }, session: set_session_user(caller)
      end

      assert_response :created
      assert_equal @user, assigns(:ssh_key).user
    end

    it 'does not create an SSH key for a user outside its edit_users filter' do
      caller = FactoryBot.create(:user)
      allowed_user = FactoryBot.create(:user)
      setup_user('create', 'ssh_keys', nil, caller)
      setup_user('edit', 'users', "id = #{allowed_user.id}", caller)

      assert_no_difference('SshKey.count') do
        post :create, params: { :ssh_key => valid_attrs, :user_id => @user.id }, session: set_session_user(caller)
      end

      assert_response :not_found
    end
  end
end
