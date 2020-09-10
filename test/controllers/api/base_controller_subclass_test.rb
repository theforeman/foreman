require 'test_helper'
require 'minitest/autorun'

class Api::TestableController < Api::V2::BaseController
  before_action :find_required_nested_object, :only => [:required_nested_values, :nested_values]
  before_action :find_optional_nested_object, :only => [:optional_nested_values]
  before_action :find_resource, :only => [:nested_values]

  def index
    render :plain => Time.zone.name, :status => :ok
  end

  def raise_error
    render_error 'standard_error', :status => :internal_server_error,
                                   :locals => { :exception => StandardError }
  end

  def required_nested_values
    render :plain => Time.zone.name, :status => :ok
  end

  def optional_nested_values
    render :plain => Time.zone.name, :status => :ok
  end

  def nested_values
    render :plain => @testable.to_s, :status => :ok
  end

  def authorized
    true
  end

  def action_permission
    case params[:action]
    when 'nested_values', 'required_nested_values', 'optional_nested_values', 'raise_error', 'authorized'
      :view
    else
      super
    end
  end
end

class Testable < ApplicationRecord
  include Authorizable
  belongs_to :domain
  belongs_to :foo, :foreign_key => 'role_id'
  self.table_name = 'filters'
end

class Foo < ApplicationRecord
  self.table_name = 'roles'
  has_many :testables
end

class Api::TestableControllerTest < ActionController::TestCase
  tests Api::TestableController

  context "api base headers" do
    setup do
      @organization = FactoryBot.create :organization, :name => "org"
      @location = FactoryBot.create :location, :name => "loc"
    end
    test "should contain version in headers" do
      get :index
      assert_match /\d+\.\d+/, @response.headers["Foreman_version"]
    end

    test "should contain version as string in headers" do
      get :index
      assert @response.headers["Foreman_version"].is_a? String
    end

    test "should contain ANY location and ANY Organization in the headers" do
      get :index
      assert_equal @response.headers["Foreman_current_organization"], "; ANY"
      assert_equal @response.headers["Foreman_current_location"], "; ANY"
    end

    test "should contain current location and organization in the headers" do
      get :index, :params => { :location_id => @location.id, :organization_id => @organization.id }
      assert_equal @response.headers["Foreman_current_organization"], "#{@organization.id}; #{@organization.name}"
      assert_equal @response.headers["Foreman_current_location"], "#{@location.id}; #{@location.name}"
    end
  end

  context "API session expiration" do
    context "with credentials being sent" do
      test "request succeeds if there's no existing session" do
        # this would be typical API call initiated directly or from cli
        get :index
        assert_response :success
      end

      test "request fails even if the session expired" do
        # this would be typical API call  initiated directly or from cli
        get :index, session: { :expires_at => 5.days.ago.utc, :user => users(:apiadmin).id }
        assert_response :unauthorized
      end
    end

    context "without credentials being sent" do
      setup do
        reset_api_credentials
      end

      test "request fails if the session expired" do
        # this would be typical API call  initiated from a web ui session
        get :index, session: { :expires_at => 5.days.ago.utc, :user => users(:apiadmin).id }
        assert_response :unauthorized
      end

      test "request succeeds if the session has not expired" do
        # this would be typical API call  initiated from a web ui session
        get :index, session: { :expires_at => 5.days.from_now.utc, :user => users(:apiadmin).id }
        assert_response :success
      end
    end
  end

  context "API usage when authentication is enabled" do
    setup do
      User.current = nil
      reset_api_credentials
    end

    it "requires a username and password" do
      @controller.stubs(:available_sso).returns(nil)
      get :index
      assert_response :unauthorized
    end

    it "prevents brute-force attempts" do
      @controller.expects(:authenticate).times(30).returns(false)
      @controller.expects(:log_bruteforce).once
      31.times do
        get :index, params: { :user => 'admin', :password => 'brute-force' }
      end
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

      it "saves user id into the session" do
        get :index
        assert_equal users(:admin).id, session[:user]
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
      User.current = nil
      reset_api_credentials
    end

    teardown do
      ActionController::Base.allow_forgery_protection = false
    end

    it "blocks access without CSRF token when there is a session user" do
      request.headers['X-CSRF-Token'] = nil
      post :index, session: set_session_user
      assert_response :unauthorized
    end

    it "permits access without CSRF token when the session was authenticated via api" do
      request.headers['X-CSRF-Token'] = nil
      post :index, session: set_session_user.merge(:api_authenticated_session => true)
      assert_response :success
    end

    it "works with a CSRF token when there is a session user" do
      token = @controller.send(:form_authenticity_token)
      request.headers['X-CSRF-Token'] = token
      post :index, params: { :authenticity_token => token }, session: set_session_user
      assert_response :success
    end
  end

  context 'using nested objects' do
    setup do
      @controller.stubs(:allowed_nested_id).returns(['domain_id'])
      @controller.stubs(:action_permission).returns('view')
      @nested_obj = FactoryBot.create(:domain, :id => 1)
    end

    it 'should return 404 error, if association not defined for required parameters' do
      get :required_nested_values, params: { :xxx_id => 1 }

      assert_equal 404, @response.status
    end

    it 'should return error, if required nested resource requested, but not found' do
      get :required_nested_values, params: { :domain_id => 2, :action => 'index' }

      assert_match /.*message.*not found.*/, @response.body
    end

    it 'should return error, if required nested resource not requested' do
      get :required_nested_values, params: { :action => 'index' }

      assert_match /.*message.*not found.*/, @response.body
    end

    it 'should not return error, if association not defined for optional parameters' do
      get :optional_nested_values, params: { :xxx_id => 1 }

      assert_equal @response.status, 200
    end

    it 'should return error, if optional nested resource requested, but not found' do
      get :optional_nested_values, params: { :domain_id => 2, :action => 'index' }

      assert_match /.*message.*not found.*/, @response.body
    end

    it 'should not return error, if optional nested resource not requested' do
      get :optional_nested_values, params: { :action => 'index' }

      assert_equal @response.status, 200
    end

    context 'resouce scoping' do
      setup do
        @foo = Foo.create
        @testable = Testable.create(:foo => @foo)
      end

      it 'should return nested resource' do
        get :nested_values, params: { :foo_id => @foo.id, :id => @testable.id }
        assert_equal @testable, @controller.instance_variable_get('@testable')
        assert_equal @foo, @controller.instance_variable_get('@nested_obj')
      end
    end

    context 'nested resource permissions' do
      setup do
        @child_associacion = mock('child_associacion')
        @testable_scope1 = mock('testable_scope1')
        @testable_scope2 = mock('testable_scope2')
        @testable_obj = mock('testable1')
        @testable_scope2.stubs(:merge).returns(@testable_scope1)
        @testable_scope2.stubs(:ids).returns([])
        @child_associacion.stubs(:merge).returns(@testable_scope1)
        @testable_scope1.stubs(:readonly).returns(@testable_scope1)
        @testable_scope1.stubs(:ids).returns([1])
        Testable.stubs(:joins).returns(@child_associacion)
      end

      context 'check authorized for nested resources' do
        it 'checks Host::Managed scope when :host_id is passed' do
          Host::Managed.expects(:authorized)
          get :nested_values, params: { :host_id => 1, :id => 1 }
        end

        it 'determines class properly from resource_id parameter' do
          Domain.expects(:authorized)
          get :nested_values, params: { :domain_id => 1, :id => 1 }
          Subnet.expects(:authorized)
          get :nested_values, params: { :subnet_id => 1, :id => 1 }
        end
      end
    end
  end

  context 'controllers uses timezone' do
    setup do
      @user = users(:admin)
      @user.update_attribute(:timezone, 'Fiji')
    end

    it 'modifies timezone only inside a controller' do
      get :index, session: { :user => @user.id, :expires_at => 5.minutes.from_now }
      # inside the controller
      assert_equal(@response.body, @user.timezone)
      # outside the controller
      refute_equal(Time.zone.name, @user.timezone)
    end

    it 'defaults to UTC timezone if user timezone and cookie are not set' do
      @user.update_attribute(:timezone, nil)
      get :index, session: { :user => @user.id, :expires_at => 5.minutes.from_now }
      assert_equal(@response.body, 'UTC')
    end

    it 'changes the timezone according to cookie when user timezone is nil' do
      @user.update_attribute(:timezone, nil)
      cookies[:timezone] = 'Australia/Sydney'
      get :index, session: { :user => @user.id, :expires_at => 5.minutes.from_now }
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

  context 'migration checker' do
    teardown do
      Foreman::Controller::MigrationChecker.instance_variable_set('@needs_migration', nil)
      ActiveRecord::MigrationContext.any_instance.unstub(:needs_migration?)
    end

    it 'fails when pending migrations' do
      Foreman::Controller::MigrationChecker.instance_variable_set('@needs_migration', nil)
      ActiveRecord::MigrationContext.any_instance.stubs(:needs_migration?).returns(true)
      get :index
      assert_response :service_unavailable
    end
  end
end
