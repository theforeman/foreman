require 'test_helper'
require 'securerandom'

class OpenidConnectTest < ActiveSupport::TestCase
  # Generates token: "eyJhbGciOiJub25lIn0.eyJuYW1lIjoiand0IHRva2VuIiwiaWF0IjoxNTU3MjI0NzU4LCJleHAiOjE1NjgyMzc4NzcsInR5cCI6IkJlYXJlciIsImF1ZCI6InJlc3QtY2xpZW50IiwiaXNzIjoiMTI3LjAuMC4xIn0."
  let(:payload) do
    { "name": "jwt token",
      "iat": 1557224758,
      "exp": Time.now.to_i + 4 * 3600,
      "typ": "Bearer",
      "aud": "rest-client",
      "iss": "127.0.0.1",
      "preferred_username": "jwt",
      "email": "jwt@test.com",
      "given_name": "jwt",
      "family_name": "family" }
  end

  let(:decoded_payload) do
    payload.with_indifferent_access
  end

  setup do
    Setting['oidc_issuer'] = '127.0.0.1'
  end

  describe '#available?' do
    test 'returns true if its a OpenID Connect session' do
      controller_with_session =
        api_controller({:sso_method => 'SSO::OpenidConnect'})
      subject = SSO::OpenidConnect.new(controller_with_session)
      assert_equal subject.available?, true
    end

    test 'if its OpenIDConnect session,' \
    'it deletes :sso_method key from session and returns true' do
      controller_with_session =
        api_controller({:sso_method => 'SSO::OpenidConnect'})
      subject = SSO::OpenidConnect.new(controller_with_session)
      assert_equal subject.available?, true
      assert_nil controller_with_session.session[:sso_method]
    end

    test 'returns false when not a api_request and no oidc header is passed' do
      subject = SSO::OpenidConnect.new(non_api_controller)
      assert_equal subject.available?, false
    end

    test 'returns true when not a api_request and a oidc header is passed' do
      token = JWT.encode(payload, nil, 'none')
      controller = non_api_controller(nil, {'HTTP_OIDC_ACCESS_TOKEN' => token.to_s})
      SSO::Base.any_instance.stubs(:http_token).returns(token)
      subject = SSO::OpenidConnect.new(controller)
      assert_equal subject.available?, true
    end

    test "returns true when api request contain valid JWT token" do
      token = JWT.encode(payload, nil, 'none')
      controller = api_controller(nil, {:authorization => "Bearer #{token}"})
      subject = SSO::OpenidConnect.new(controller)
      assert_equal subject.available?, true
    end

    test "returns false when api request contain invalid JWT issuer" do
      invalid_payload = payload
      invalid_payload['iss'] = "random_value"
      token = JWT.encode(invalid_payload, nil, 'none')
      controller = api_controller(nil, {:authorization => "Bearer #{token}"})
      subject = SSO::OpenidConnect.new(controller)
      assert_equal subject.available?, false
    end

    test "returns false when api request contain nil JWT token" do
      token = JWT.encode(nil, nil, 'none')
      controller = api_controller(nil, {:authorization => "Bearer #{token}"})
      subject = SSO::OpenidConnect.new(controller)
      assert_equal subject.available?, false
    end

    test "returns false if api request does not contain JWT token" do
      controller = api_controller()
      subject = SSO::OpenidConnect.new(controller)
      assert_equal subject.available?, false
    end
  end

  describe "#authenticated?" do
    let(:subject) do
      token = JWT.encode(payload, nil, 'none')
      SSO::OpenidConnect.new api_controller({}, {:authorization => "Bearer #{token}"})
    end

    test "it authenticates and sets user when currect user does not exists" do
      User.current = nil
      OidcJwt.any_instance.stubs(:decode).returns(decoded_payload)
      assert_equal subject.authenticated?, true
      assert subject.current_user.is_a?(User)
      assert_equal subject.current_user.login, decoded_payload['preferred_username']
    end

    test "it accepts group parameter in payload and authenticates the user" do
      oidc_source = AuthSourceExternal.where(:name => 'External').first_or_create
      external = FactoryBot.create(:external_usergroup, :auth_source => oidc_source)
      usergroup = FactoryBot.create(:usergroup, :admin => true)
      external.update(:usergroup => usergroup, :name => usergroup.name)

      User.current = nil
      payload['groups'] = [usergroup.name]
      OidcJwt.any_instance.stubs(:decode).returns(payload.with_indifferent_access)
      assert subject.authenticated?

      assert_equal payload['groups'].first, subject.current_user.usergroups.first.name
    end
  end

  private

  def non_api_controller(session = {}, headers = {})
    controller = Struct.new(:request, :session) do
      def api_request?
        false
      end
    end
    request = ActionDispatch::TestRequest.new({})
    request.headers.merge! headers
    controller.new(request, session)
  end

  def api_controller(session = {}, headers = {})
    controller = Struct.new(:request, :session) do
      def api_request?
        true
      end
    end
    request = ActionDispatch::TestRequest.new({})
    request.headers.merge! headers
    controller.new(request, session)
  end
end
