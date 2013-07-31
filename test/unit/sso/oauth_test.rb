require 'test_helper'

class OauthTest < ActiveSupport::TestCase
  setup :oauth_settings

  test 'oauth available in good conditions' do
    oauth = SSO::Oauth.new(get_controller(true))
    assert oauth.available?
  end

  test 'oauth not available for non api requests' do
    oauth = SSO::Oauth.new(get_controller(false))
    assert !oauth.available?
  end

  test 'authenticates if user.current is not set' do
    User.current = nil
    oauth = SSO::Oauth.new(get_controller(true))
    oauth.expects(:authenticate!).times(1).returns('testuser')
    assert_equal 'testuser', oauth.authenticated?
  end

  test 'does not reauthenticate if user.current is set' do
    User.current = users(:one)
    oauth = SSO::Oauth.new(get_controller(true))
    assert_equal users(:one), oauth.authenticated?
  end

  def get_controller(api_request)
    controller = Struct.new(:request).new(Struct.new(:authorization).new('OAuth'))
    stub(controller).headers { { 'foreman_user' => 'testuser' } }
    stub(controller).api_request? { api_request }
    controller
  end

  protected
  def oauth_settings
    Setting.create!(:name => 'oauth_active', :description => 'test', :default => false, :value => true )
  end
end
