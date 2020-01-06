require 'test_helper'

class JwtTest < ActiveSupport::TestCase
  setup do
    User.current = nil
  end

  context 'api request' do
    let(:token) { users(:one).jwt_token! }
    let(:controller) { get_controller(true, token) }
    let(:sso) { SSO::Jwt.new(controller) }

    test 'jwt is available' do
      assert sso.available?
    end

    test 'jwt not available when bearer token not present' do
      controller = get_controller(true, nil)
      sso = SSO::Jwt.new(controller)
      assert_equal false, sso.available?
    end

    test 'jwt not available when token has a issuer' do
      token_with_issuer = "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo5ODAxOTA5NjIsImlhdCI6MTU3OTM0MDc4NywiaXNzIjoiaHR0cHM6Ly9zc28uZXhhbXBsZS5jb20iLCJqdGkiOiJkMzdhZGVkNjM3ZWVmY2E0MmEwNDg0YzRlMDM0OTlhNTBmZGQzMmQwYWQ5NjU5ZDJiNjU5Mzg5ZjY0ZjkxOTdhIn0.oZcgfeTN6oKYJ8-1YxfumOA_8WSCOrmfPvxBygMluHM"
      controller = get_controller(true, token_with_issuer)
      sso = SSO::Jwt.new(controller)
      assert_equal false, sso.available?
    end

    test 'does not reauthenticate if user.current is set' do
      as_user(:one) do
        sso.expects(:authenticate!).never
        assert_equal users(:one), sso.authenticated?
      end
    end

    context 'with valid token' do
      test '#authenticate! authenticates a user' do
        assert_equal users(:one).login, sso.authenticated?
        assert_equal users(:one).login, sso.user
        assert_equal users(:one), sso.current_user
      end
    end

    context 'with invalid token' do
      let(:token) { 'invalid' }
      test '#authenticate! does not set user' do
        assert_nil sso.authenticated?
        assert_nil sso.user
        assert_nil sso.current_user
      end
    end

    context "with token signed with another user's secret" do
      let(:token) { JwtToken.encode(users(:one), users(:two).jwt_secret!.token) }

      test '#authenticate! does not set user' do
        assert_nil sso.authenticated?
        assert_nil sso.user
        assert_nil sso.current_user
      end
    end
  end

  context 'no api request' do
    let(:controller) { get_controller(false) }
    let(:sso) { SSO::Jwt.new(controller) }

    test 'jwt is not available' do
      refute sso.available?
    end
  end

  protected

  def get_controller(api_request, jwt_token = 'invalid', headers = {})
    controller = Struct.new(:request).new(Struct.new(:authorization, :headers).new("Bearer #{jwt_token}", headers))
    controller.stubs(:api_request?).returns(api_request)
    controller.stubs(:session).returns(ActionController::TestSession.new)
    controller
  end
end
