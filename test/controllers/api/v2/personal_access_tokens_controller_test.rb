require 'test_helper'

class Api::V2::PersonalAccessTokensControllerTest < ActionController::TestCase
  let(:expiry_date) do
    4.weeks.from_now
  end
  let(:valid_attrs) do
    {
      :name => 'foreman@example.com',
      :expires_at => expiry_date.iso8601,
    }
  end

  def setup
    @user = FactoryBot.create(:user)
    @personal_access_token = FactoryBot.create(:personal_access_token, :user => @user)
    FactoryBot.create(:permission, :name => 'create_personal_access_tokens', :resource_type => 'PersonalAccessToken')
  end

  test "should get index" do
    get :index, params: { :user_id => @user.id }
    assert_response :success
    assert_not_nil assigns(:personal_access_tokens)
    personal_access_tokens = ActiveSupport::JSON.decode(@response.body)
    assert !personal_access_tokens.empty?
  end

  test "should show individual record" do
    get :show, params: { :id => @personal_access_token.to_param, :user_id => @user.id }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create personal_access_token" do
    assert_difference('PersonalAccessToken.count') do
      post :create, params: { :personal_access_token => valid_attrs, :user_id => @user.id }
    end
    assert_response :created
    response = ActiveSupport::JSON.decode(@response.body)
    assert response['token_value'].present?
    assert_equal Time.at(expiry_date.to_i), Time.at(response['expires_at'].to_time.to_i)
  end

  test "should created personal_access_token with unwrapped 'layout'" do
    assert_difference('PersonalAccessToken.count') do
      post :create, params: valid_attrs.merge(:user_id => @user.id)
    end
    assert_response :created
  end

  test "should revoke personal_access_token" do
    refute @personal_access_token.reload.revoked?
    delete :destroy, params: { :id => @personal_access_token.to_param, :user_id => @user.id }
    assert @personal_access_token.reload.revoked?
    assert_response :success
  end

  context 'with non-admin user' do
    it 'allows creating a token for itself without create permission' do
      caller = FactoryBot.create(:user)

      assert_difference('PersonalAccessToken.count') do
        post :create, params: { personal_access_token: valid_attrs, user_id: caller.id }, session: set_session_user(caller)
      end

      assert_response :created
      response = ActiveSupport::JSON.decode(@response.body)
      assert_equal caller.id, response['user_id']
      assert response['token_value'].present?
    end

    it 'does not create a token for a user it cannot edit' do
      caller = FactoryBot.create(:user)
      setup_user('create', 'personal_access_tokens', nil, caller)

      assert_no_difference('PersonalAccessToken.count') do
        post :create, params: { personal_access_token: valid_attrs, user_id: @user.id }, session: set_session_user(caller)
      end

      assert_response :not_found
      refute_includes @response.body, 'token_value'
    end

    it 'does not create a token for another user without create permission' do
      caller = FactoryBot.create(:user)
      setup_user('edit', 'users', nil, caller)

      assert_no_difference('PersonalAccessToken.count') do
        post :create, params: { personal_access_token: valid_attrs, user_id: @user.id }, session: set_session_user(caller)
      end

      assert_response :forbidden
      refute_includes @response.body, 'token_value'
    end

    it 'creates a token for a user it can edit with create permission' do
      caller = FactoryBot.create(:user)
      setup_user('create', 'personal_access_tokens', nil, caller)
      setup_user('edit', 'users', nil, caller)

      assert_difference('PersonalAccessToken.count') do
        post :create, params: { personal_access_token: valid_attrs, user_id: @user.id }, session: set_session_user(caller)
      end

      assert_response :created
      response = ActiveSupport::JSON.decode(@response.body)
      assert_equal @user.id, response['user_id']
      assert response['token_value'].present?
    end

    it 'creates a token for a user in its edit_users filter' do
      caller = FactoryBot.create(:user)
      setup_user('create', 'personal_access_tokens', nil, caller)
      setup_user('edit', 'users', "id = #{@user.id}", caller)

      assert_difference('PersonalAccessToken.count') do
        post :create, params: { personal_access_token: valid_attrs, user_id: @user.id }, session: set_session_user(caller)
      end

      assert_response :created
      response = ActiveSupport::JSON.decode(@response.body)
      assert_equal @user.id, response['user_id']
      assert response['token_value'].present?
    end

    it 'does not create a token for a user outside its edit_users filter' do
      caller = FactoryBot.create(:user)
      allowed_user = FactoryBot.create(:user)
      setup_user('create', 'personal_access_tokens', nil, caller)
      setup_user('edit', 'users', "id = #{allowed_user.id}", caller)

      assert_no_difference('PersonalAccessToken.count') do
        post :create, params: { personal_access_token: valid_attrs, user_id: @user.id }, session: set_session_user(caller)
      end

      assert_response :not_found
      refute_includes @response.body, 'token_value'
    end

    it 'allows to revoke his token' do
      setup_user('edit', 'users', nil, @user)
      setup_user('revoke', 'personal_access_tokens', nil, @user)
      delete :destroy, params: { id: @personal_access_token.to_param, user_id: @user.id }, session: set_session_user(@user)
      assert_response :success
      assert @personal_access_token.reload.revoked?
    end
  end
end
