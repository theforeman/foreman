require 'test_helper'

class Api::V2::TestableController < Api::V2::BaseController
  def index
    render :plain => 'dummy', :status => :ok
  end

  def create
    render :plain => 'dummy', :status => :ok
  end

  def new
    nil.id
  end
end

class Api::V2::TestableControllerTest < ActionController::TestCase
  tests Api::V2::TestableController

  context "non-json requests" do
    def setup
      @request.env['CONTENT_TYPE'] = 'application/x-www-form-urlencoded'
    end

    test "should return 415 for POST/PUT" do
      post :create
      assert_response 415
    end

    test "should return 200 for GET" do
      get :index
      assert_response 200
    end
  end

  context "when authentication is enabled" do
    setup do
      User.current = nil
    end

    context 'with dummy sso' do
      setup do
        @sso = mock('dummy_sso')
        @sso.stubs(:authenticated?).returns(true)
        @sso.stubs(:current_user).returns(users(:admin))
        @sso.stubs(:support_expiration?).returns(true)
        @sso.stubs(:expiration_url).returns("/users/extlogin")
        @sso.stubs(:controller).returns(@controller)
        @controller.instance_variable_set(:@available_sso, @sso)
        @controller.stubs(:get_sso_method).returns(@sso)
      end

      it "sets the session user" do
        get :index
        assert_response :success
        assert_equal users(:admin).id, session[:user]
      end
    end

    context 'with basic auth via internal sso' do
      let(:user) { as_admin { FactoryBot.create(:user, :admin) } }

      test '#login authenticates user with personal access token' do
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user.login, 'password')
        get :index
        assert_response :success
        assert_equal user.id, session[:user]
      end

      context 'personal access tokens' do
        let(:token) { as_admin { FactoryBot.create(:personal_access_token, :user => user) } }
        let(:token_value) do
          as_admin do
            token_value = token.generate_token
            token.save
            token_value
          end
        end

        test '#login authenticates user with personal access token' do
          request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user.login, token_value)
          get :index
          assert_response :success
          assert_equal user.id, session[:user]
        end
      end
    end

    context 'with jwt auth' do
      let(:sso) { SSO::Jwt.new(@controller) }
      let(:user) { as_admin { FactoryBot.create(:user, :admin) } }
      let(:jwt_token) { user.jwt_token! }

      setup do
        @controller.instance_variable_set(:@available_sso, sso)
        @controller.stubs(:get_sso_method).returns(sso)
        @request.headers['Authorization'] = "Bearer #{jwt_token}"
      end

      test 'it sets the session user' do
        get :index
        assert_response :success
        assert_equal user.id, session[:user]
      end
    end
  end

  test "should have server error message" do
    get :new
    assert_response 500
    msg = "Internal Server Error: the server was unable to finish the request. "
    msg << "This may be caused by unavailability of some required service, incorrect API call or a server-side bug. "
    msg << "There may be more information in the server's logs."
    assert_equal JSON.parse(response.body)['error']['message'], msg
  end
end
