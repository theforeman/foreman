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

  context "API session expiration" do
    test "request succeeds if no session[:expires_at] is included" do
      # this would be typical of API initiated directly or from cli
      get :index
      assert_response :success
    end

    test "request fails if session expired" do
      # this would be typical of API initiated from a web ui session
      get :index, {}, { :expires_at => 5.days.ago.utc }
      assert_response :unauthorized
    end

    test "request succeeds if session has not expired" do
      # this would be typical of API initiated from a web ui session
      get :index, {}, { :expires_at => 5.days.from_now.utc }
      assert_response :success
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

    it "uses an accessible admin user" do
      User.unscoped.except_hidden.only_admin.where('login <> ?', users(:apiadmin).login).destroy_all
      @controller.expects(:set_current_user).with(responds_with(:login, users(:apiadmin).login)).returns(true)
      get :index
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
        @sso.stubs(:current_user).returns(users(:admin))
        @controller.stubs(:available_sso).returns(@sso)
      end

      it "permits access" do
        get :index
        assert_response :success
      end

      it "sets the admin user" do
        @controller.expects(:set_current_user).with(responds_with(:login, users(:admin).login)).returns(true)
        get :index
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

  context 'CSRF' do
    setup do
      ActionController::Base.allow_forgery_protection = true
      SETTINGS[:login] = true
      User.current = nil
      request.env['HTTP_AUTHORIZATION'] = nil
    end

    teardown do
      ActionController::Base.allow_forgery_protection = false
    end

    it "blocks access without CSRF token when there is a session user" do
      request.headers['X-CSRF-Token'] = nil
      post :index, {}, set_session_user
      assert_response :unauthorized
    end

    it "works with a CSRF token when there is a session user" do
      request.headers['X-CSRF-Token'] = 'TEST_TOKEN'
      post :index, {:authenticity_token => 'TEST_TOKEN'}, set_session_user.merge(:_csrf_token => 'TEST_TOKEN')
      assert_response :success
    end
  end

  context 'nested objects' do
    it "should use auth scope of nested object" do
      ctrl = Api::TestableController.new
      ctrl.expects(:params).at_least_once.returns(HashWithIndifferentAccess.new(:domain_id => 1, :action => 'index'))
      ctrl.expects(:allowed_nested_id).at_least_once.returns(['domain_id'])
      scope = mock('scope')
      obj = mock('domain')
      scope.expects(:find).with(1).returns(obj)
      Domain.expects(:authorized).with('view_domains').returns(scope)
      assert_equal obj, ctrl.send(:find_required_nested_object)
    end
  end
end
