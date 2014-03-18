require 'test_helper'

class Api::TestableController < Api::V1::BaseController
  def index
    render :text => 'dummy', :status => 200
  end

  def raise_error
    render_error 'standard_error', :status => :internal_server_error,
                                   :locals => { :exception => StandardError }
  end
end

class Api::TestableControllerTest < ActionController::TestCase
  tests Api::TestableController

  context "api base headers" do
    test "should contain version in headers" do
      get :index
      assert_match /\d+\.\d+/, @response.headers["Foreman_version"]
    end

    test "should contain version as string in headers" do
      get :index
      assert @response.headers["Foreman_version"].is_a? String
    end
  end

  context "API usage when authentication is disabled" do
    setup do
      User.current = nil
      request.env['HTTP_AUTHORIZATION'] = nil
      SETTINGS[:login] = false
    end

    teardown do
      SETTINGS[:login] = true
    end

    it "does not need a username and password" do
      get :index
      assert_response :success
    end

    it "does not set session data for API requests" do
      get :index
      assert_not session[:user]
    end
  end

  context "API usage when authentication is enabled" do
    setup do
      User.current = nil
      request.env['HTTP_AUTHORIZATION'] = nil
      SETTINGS[:login] = true
    end

    it "requires a username and password" do
      @controller.stubs(:available_sso).returns(nil)
      get :index
      assert_response :unauthorized
    end

    context "and SSO (plain) authenticates" do
      setup do
        @sso = mock('dummy_sso')
        @sso.stubs(:authenticated?).returns(true)
        @sso.stubs(:user).returns(users(:admin).login)
        @controller.stubs(:available_sso).returns(@sso)
      end

      it "doesn't escalate privileges in the session" do
        get :index
        refute session[:user], "session contains user #{session[:user]}"
      end
    end
  end

  context 'errors' do
    test "top level key is error, no metadata included" do
      get :raise_error
      assert_equal ['error'], ActiveSupport::JSON.decode(@response.body).keys
    end
  end
end
