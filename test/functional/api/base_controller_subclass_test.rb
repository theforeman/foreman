require 'test_helper'

class Api::TestableController < Api::V1::BaseController
  before_filter :find_required_nested_object, :only => [:required_nested_values, :nested_values]
  before_filter :find_optional_nested_object, :only => [:optional_nested_values]
  before_filter :find_resource, :only => [:nested_values]

  def index
    render :text => Time.zone.name, :status => 200
  end

  def raise_error
    render_error 'standard_error', :status => :internal_server_error,
                                   :locals => { :exception => StandardError }
  end

  def required_nested_values
    render :text => Time.zone.name, :status => 200
  end

  def optional_nested_values
    render :text => Time.zone.name, :status => 200
  end

  def nested_values
    render :text => @testable.to_s, :status => 200
  end

  def authorized
    true
  end
end

class Testable < ActiveRecord::Base
  belongs_to :domain
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

  context 'using nested objects' do
    setup do
      @controller.stubs(:allowed_nested_id).returns(['domain_id'])
      @controller.stubs(:action_permission).returns('view')
      @nested_obj = FactoryGirl.create(:domain, :id => 1)
    end

    it 'should return 404 error, if association not defined for required parameters' do
      get :required_nested_values, :xxx_id => 1

      assert_equal 404, @response.status
    end

    it 'should return error, if required nested resource requested, but not found' do
      get :required_nested_values, :domain_id => 2, :action => 'index'

      assert_match /.*message.*not found.*/, @response.body
    end

    it 'should return error, if required nested resource not requested' do
      get :required_nested_values, :action => 'index'

      assert_match /.*message.*not found.*/, @response.body
    end

    it 'should not return error, if association not defined for optional parameters' do
      get :optional_nested_values, :xxx_id => 1

      assert_equal @response.status, 200
    end

    it 'should return error, if optional nested resource requested, but not found' do
      get :optional_nested_values, :domain_id => 2, :action => 'index'

      assert_match /.*message.*not found.*/, @response.body
    end

    it 'should not return error, if optional nested resource not requested' do
      get :optional_nested_values, :action => 'index'

      assert_equal @response.status, 200
    end

    context 'nested resource permissions' do
      setup do
        @child_associacion = mock('child_associacion')
        @testable_scope1 = mock('testable_scope1')
        @testable_scope2 = mock('testable_scope2')
        @testable_obj = mock('testable1')
        @testable_scope2.stubs(:merge).returns(@testable_scope1)
        @child_associacion.stubs(:merge).returns(@testable_scope1)
        @testable_scope1.stubs(:readonly).returns(@testable_scope1)
        Testable.stubs(:joins).returns(@child_associacion)
      end

      context 'resouce scope mocks' do
        setup do
          @testable_scope1.expects(:find).with('1').returns(@testable_obj)
          @testable_scope1.expects(:empty?).returns(false)
        end

        it 'should return nested resource for unauthorized resource' do
          Testable.stubs(:where).returns(@testable_scope2)
          Testable.stubs(:scoped).returns(@testable_scope2)

          get :nested_values, :domain_id => 1, :id => 1

          assert_equal @testable_obj, @controller.instance_variable_get('@testable')
          assert_equal @nested_obj, @controller.instance_variable_get('@nested_obj')
        end

        it 'should return nested resource scope for authorized resource' do
          child_auth_scope = mock('child_auth_scope')

          Testable.stubs(:authorized).returns(child_auth_scope)
          child_auth_scope.stubs(:where).returns(@testable_scope2)
          child_auth_scope.stubs(:scoped).returns(@testable_scope2)

          get :nested_values, :domain_id => 1, :id => 1

          assert_equal @testable_obj, @controller.instance_variable_get('@testable')
          assert_equal @nested_obj, @controller.instance_variable_get('@nested_obj')
        end
      end

      context 'check authorized for nested resources' do
        it 'checks Host::Managed scope when :host_id is passed' do
          Host::Managed.expects(:authorized)
          get :nested_values, :host_id => 1, :id => 1
        end

        it 'determines class properly from resource_id parameter' do
          Domain.expects(:authorized)
          get :nested_values, :domain_id => 1, :id => 1
          Subnet.expects(:authorized)
          get :nested_values, :subnet_id => 1, :id => 1
        end
      end
    end
  end

  context 'controllers uses timezone' do
    setup do
      SETTINGS[:login] = true
      @user = users(:admin)
      @user.update_attribute(:timezone, 'Fiji')
    end

    it 'modifies timezone only inside a controller' do
      get :index, {}, {:user => @user.id, :expires_at => 5.minutes.from_now}
      # inside the controller
      assert_equal(@response.body, @user.timezone)
      # outside the controller
      refute_equal(Time.zone.name, @user.timezone)
    end

    it 'defaults to UTC timezone if user timezone and cookie are not set' do
      @user.update_attribute(:timezone, nil)
      get :index, {}, {:user => @user.id, :expires_at => 5.minutes.from_now}
      assert_equal(@response.body, 'UTC')
    end

    it 'changes the timezone according to cookie when user timezone is nil' do
      @user.update_attribute(:timezone, nil)
      cookies[:timezone] = 'Australia/Sydney'
      get :index, {}, {:user => @user.id, :expires_at => 5.minutes.from_now}
      assert_equal(@response.body, cookies[:timezone])
    end
  end

  describe '#resource_scope' do
    it 'uses controller name for permission name suffix by default' do
      @controller.expects(:action_permission).returns('view')
      Testable.expects(:authorized).with('view_testable', Testable).returns(Testable)
      @controller.resource_scope
    end

    it 'uses controller_permission for permission name suffix' do
      @controller.expects(:controller_permission).returns('example')
      @controller.expects(:action_permission).returns('view')
      Testable.expects(:authorized).with('view_example', Testable).returns(Testable)
      @controller.resource_scope
    end

    it 'uses :controller option for permission name suffix if set' do
      @controller.expects(:controller_permission).never
      @controller.expects(:action_permission).returns('view')
      Testable.expects(:authorized).with('view_example', Testable).returns(Testable)
      @controller.resource_scope(:controller => 'example')
    end

    it 'uses :permission option for permission name if set' do
      @controller.expects(:action_permission).never
      Testable.expects(:authorized).with('overridden', Testable).returns(Testable)
      @controller.resource_scope(:permission => 'overridden')
    end
  end
end
