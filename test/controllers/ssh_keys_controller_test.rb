require 'test_helper'

class SshKeysControllerTest < ActionController::TestCase
  let(:key) { 'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBIhRoL6PfBRs9YwW3r2/pYeLrxRzEZSUO3Go8JivxMsguEKjJ3byHDPvPpMHhKKSZD/HJY/A+2Ndqp0ElB+t2qs= foreman@example.com' }
  let(:ssh_key) { FactoryBot.create(:ssh_key) }
  let(:user) { ssh_key.user }

  test 'new' do
    get :new, params: { :user_id => user.id }, session: set_session_user
    assert_template 'new'
  end

  test 'create_invalid' do
    post :create, params: { :ssh_key => {:name => nil}, :user_id => user.id }, session: set_session_user
    assert_template 'new'
  end

  test 'create_valid' do
    user
    assert_difference 'SshKey.count', 1 do
      post :create, params: { :ssh_key => { :name => 'dummy', :key => key}, :user_id => user.id }, session: set_session_user
    end
    assert_redirected_to edit_user_url(user)
  end

  test 'destroy' do
    delete :destroy, params: { :id => ssh_key.id, :user_id => user.id }, session: set_session_user
    assert_redirected_to edit_user_url(user)
    refute SshKey.exists?(ssh_key.id)
  end
end
