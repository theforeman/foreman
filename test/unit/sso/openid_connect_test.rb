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
      assert_equal true, subject.available?
    end

    test 'if its OpenIDConnect session,' \
    'it deletes :sso_method key from session and returns true' do
      controller_with_session =
        api_controller({:sso_method => 'SSO::OpenidConnect'})
      subject = SSO::OpenidConnect.new(controller_with_session)
      assert_equal true, subject.available?
      assert_nil controller_with_session.session[:sso_method]
    end

    test 'returns false when not a api_request and no oidc header is passed' do
      subject = SSO::OpenidConnect.new(non_api_controller)
      assert_equal false, subject.available?
    end

    test 'returns true when not a api_request and a JWT oidc access token is passed' do
      token = JWT.encode(payload, nil, 'none')
      controller = non_api_controller(nil, {'HTTP_OIDC_ACCESS_TOKEN' => token.to_s})
      subject = SSO::OpenidConnect.new(controller)
      assert_equal true, subject.available?
    end

    test 'returns true when not a api_request and a plain oidc access token with id_token payload is passed' do
      controller = non_api_controller(nil, {
        'HTTP_OIDC_ACCESS_TOKEN' => '593fb2dfc385a1550ec43ddd60edbf6c',
        'HTTP_OIDC_ID_TOKEN_PAYLOAD' => JSON.generate(payload),
      })
      subject = SSO::OpenidConnect.new(controller)
      assert_equal true, subject.available?
    end

    test "returns true when api request contain valid JWT token" do
      token = JWT.encode(payload, nil, 'none')
      controller = api_controller(nil, {:authorization => "Bearer #{token}"})
      subject = SSO::OpenidConnect.new(controller)
      assert_equal true, subject.available?
    end

    test "returns false when api request contain invalid JWT issuer" do
      invalid_payload = payload
      invalid_payload['iss'] = "random_value"
      token = JWT.encode(invalid_payload, nil, 'none')
      controller = api_controller(nil, {:authorization => "Bearer #{token}"})
      subject = SSO::OpenidConnect.new(controller)
      assert_equal false, subject.available?
    end

    test "returns false when api request contain nil JWT token" do
      token = JWT.encode(nil, nil, 'none')
      controller = api_controller(nil, {:authorization => "Bearer #{token}"})
      subject = SSO::OpenidConnect.new(controller)
      assert_equal false, subject.available?
    end

    test "returns false if api request does not contain JWT token" do
      controller = api_controller()
      subject = SSO::OpenidConnect.new(controller)
      assert_equal false, subject.available?
    end
  end

  describe "#authenticated? with keycloak oidc provider" do
    let(:subject) do
      token = JWT.encode(payload, nil, 'none')
      SSO::OpenidConnect.new api_controller({}, {:authorization => "Bearer #{token}"})
    end

    test "it authenticates and creates user when current user does not exist" do
      User.current = nil
      assert_equal true, subject.authenticated?
      assert subject.current_user.is_a?(User)
      assert_equal decoded_payload['preferred_username'], subject.current_user.login
      assert_equal "#{decoded_payload['given_name']} #{decoded_payload['family_name']}", subject.current_user.name
      assert_equal decoded_payload['email'], subject.current_user.mail
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

  describe "#authenticated? with gitlab oidc provider" do
    let(:gitlab_id_token_payload) do
      { "iss": "127.0.0.1",
        "nickname": "test_username",
        "email": "test_email@example.com" }
    end
    let(:gitlab_userinfo_json) do
      { "name": "test name" }
    end
    let(:subject) do
      SSO::OpenidConnect.new non_api_controller({}, {
        'HTTP_OIDC_ACCESS_TOKEN' => '593fb2dfc385a1550ec43ddd60edbf6c',
        'HTTP_OIDC_ID_TOKEN_PAYLOAD' => JSON.generate(gitlab_id_token_payload),
        'HTTP_OIDC_USERINFO_JSON' => JSON.generate(gitlab_userinfo_json),
      })
    end

    test "it authenticates and creates user when current user does not exist" do
      User.current = nil
      assert_equal true, subject.authenticated?
      assert subject.current_user.is_a?(User)
      assert_equal 'test_username', subject.current_user.login
      assert_equal 'test name ', subject.current_user.name
      assert_equal 'test_email@example.com', subject.current_user.mail
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
