require 'test_helper'

class Api::V2::SshKeysControllerTest < ActionController::TestCase
  valid_attrs = {
    :name => 'foreman@example.com',
    :key => 'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBIhRoL6PfBRs9YwW3r2/pYeLrxRzEZSUO3Go8JivxMsguEKjJ3byHDPvPpMHhKKSZD/HJY/A+2Ndqp0ElB+t2qs= foreman@example.com'
  }

  def setup
    @user = FactoryGirl.create(:user)
    @ssh_key = FactoryGirl.create(:ssh_key, :user => @user)
  end

  test "should get index" do
    get :index, { :user_id => @user.id }
    assert_response :success
    assert_not_nil assigns(:ssh_keys)
    ssh_keys = ActiveSupport::JSON.decode(@response.body)
    assert !ssh_keys.empty?
  end

  test "should show individual record" do
    get :show, { :id => @ssh_key.to_param, :user_id => @user.id }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create ssh_key" do
    assert_difference('SshKey.count') do
      post :create, { :ssh_key => valid_attrs, :user_id => @user.id }
    end
    assert_response :created
  end

  test "should created ssh_key with unwrapped 'layout'" do
    assert_difference('SshKey.count') do
      post :create, valid_attrs.merge(:user_id => @user.id)
    end
    assert_response :created
  end

  test "should destroy ssh_key" do
    assert_difference('SshKey.count', -1) do
      delete :destroy, { :id => @ssh_key.to_param, :user_id => @user.id }
    end
    assert_response :success
  end
end
