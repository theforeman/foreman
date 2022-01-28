require 'test_helper'

class OauthTest < ActiveSupport::TestCase
  setup do
    User.current = nil
    Setting[:oauth_active] = true
    Setting['oauth_consumer_key'] = 'oauth_key'
    Setting['oauth_consumer_secret'] = 'oauth_secret'
  end

  test 'oauth available in good conditions' do
    oauth = SSO::Oauth.new(get_controller(true))
    assert oauth.available?
  end

  test 'oauth not available for non api requests' do
    oauth = SSO::Oauth.new(get_controller(false))
    assert !oauth.available?
  end

  context 'oauth_map_users is true' do
    setup do
      Setting[:oauth_map_users] = true
    end

    test 'authenticates if user.current is not set' do
      oauth = SSO::Oauth.new(get_controller(true))
      oauth.expects(:authenticate!).times(1).returns('testuser')
      assert_equal 'testuser', oauth.authenticated?
    end

    test 'does not reauthenticate if user.current is set' do
      User.current = users(:one)
      oauth = SSO::Oauth.new(get_controller(true))
      oauth.expects(:authenticate!).never
      assert_equal users(:one), oauth.authenticated?
    end

    test 'authenticates normal user' do
      controller = get_controller(true, {'HTTP_FOREMAN_USER' => users(:one).login})
      oauth = SSO::Oauth.new(controller)
      expect_oauth
      assert_equal users(:one).login, oauth.authenticated?
      assert_equal users(:one).login, oauth.user
      assert_equal users(:one), oauth.current_user
    end
  end

  context 'oauth_map_users is false' do
    setup do
      Setting[:oauth_map_users] = false
    end

    test 'authenticates as anonymous API admin' do
      controller = get_controller(true)
      oauth = SSO::Oauth.new(controller)
      expect_oauth
      assert_equal User::ANONYMOUS_API_ADMIN, oauth.authenticated?
      assert_equal User::ANONYMOUS_API_ADMIN, oauth.user
      assert_equal User::ANONYMOUS_API_ADMIN, oauth.current_user.try(:login)
    end
  end

  protected

  def get_controller(api_request, headers = {})
    controller = Struct.new(:request).new(Struct.new(:authorization, :headers).new('OAuth', headers))
    controller.stubs(:api_request?).returns(api_request)
    controller
  end

  def expect_oauth
    proxy = mock('oauth_proxy')
    proxy.expects(:oauth_consumer_key).returns('oauth_key')
    OAuth::RequestProxy.expects(:proxy).with(anything).returns(proxy)
    OAuth::Signature.expects(:verify).with(anything, :consumer_secret => 'oauth_secret').returns(true)
  end
end
