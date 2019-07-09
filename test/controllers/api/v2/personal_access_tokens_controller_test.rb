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
end
