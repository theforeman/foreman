require 'test_helper'

class ::TestableResourcesController < ::ApplicationController
  def self.controller_path
    "realms"
  end

  def index
    render :text => Time.zone.name, :status => 200
  end
end

class ::TestableResource < ActiveRecord::Base
  # ugly hack - causing ActiveRecord to check the resource against "realms" table in the DB.
  # If removed, the ActiveRecord will fail to find a table with name "testable_resources" which will fail tests,
  # even if there are no actual calls to the find/select... methods.
  def self.table_name
    'realms'
  end
end

module Testscope
  class TestableResourcesController < ::ApplicationController
    def self.controller_path
      "realms"
    end

    def index
      render :text => Time.zone.name, :status => 200
    end
  end

  class TestableResource < ActiveRecord::Base
    # ugly hack - causing ActiveRecord to check the resource against "realms" table in the DB.
    # If removed, the ActiveRecord will fail to find a table with name "testable_resources" which will fail tests,
    # even if there are no actual calls to the find/select... methods.
    def self.table_name
      'realms'
    end
  end
end

class TestableResourcesControllerTest < ActionController::TestCase
  tests ::TestableResourcesController

  context "when authentication is disabled" do
    setup do
      User.current = nil
      SETTINGS[:login] = false
    end

    teardown do
      SETTINGS[:login] = true
    end

    it "does not need a username and password" do
      get :index
      assert_response :success
    end
  end

  context "when authentication is enabled" do
    setup do
      User.current = nil
      SETTINGS[:login] = true
    end

    it "requires a username and password" do
      get :index
      assert_response :redirect
    end

    it "retains original request URI in session" do
      get :index
      assert_equal '/realms', session[:original_uri]
    end

    it "requires an account with mail" do
      user = FactoryGirl.create(:user)
      get :index, {}, set_session_user.merge(:user => user.id)
      assert_response :redirect
      assert_redirected_to edit_user_path(user)
      assert_equal "An email address is required, please update your account details", flash[:error]
    end

    context "and SSO authenticates" do
      setup do
        @sso = mock('dummy_sso')
        @sso.stubs(:authenticated?).returns(true)
        @sso.stubs(:current_user).returns(users(:admin))
        @sso.stubs(:support_expiration?).returns(true)
        @sso.stubs(:expiration_url).returns("/users/extlogin")
        @controller.stubs(:available_sso).returns(@sso)
        @controller.stubs(:get_sso_method).returns(@sso)
      end

      it "sets the session user" do
        get :index
        assert_response :success
        assert_equal users(:admin).id, session[:user]
      end

      it "redirects correctly on expiry" do
        get :index
        session[:expires_at] = 5.minutes.ago
        get :index
        assert_redirected_to "/users/extlogin"
      end

      it "changes the session ID to prevent fixation" do
        @controller.expects(:reset_session)
        get :index
      end

      it "doesn't escalate privileges in the old session" do
        old_session = session
        get :index
        refute old_session.keys.include?(:user), "old session contains user"
        assert session[:user], "new session doesn't contain user"
      end

      it "retains taxonomy session attributes in new session" do
        get :index, {}, {:location_id => taxonomies(:location1).id,
                         :organization_id => taxonomies(:organization1).id,
                         :foo => 'bar'}
        assert_equal taxonomies(:location1).id, session[:location_id]
        assert_equal taxonomies(:organization1).id, session[:organization_id]
        refute session[:foo], "session contains 'foo', but should have been reset"
      end
    end
  end

  context "can filter parameters" do
    setup do
      @controller.class.send(:include, Foreman::Controller::FilterParameters)
      @params = {'foo' => 'foo', 'name' => 'name', 'id' => 'id' }
      @request = OpenStruct.new({:filtered_parameters => @params.clone })
      @controller.stubs(:request).returns(@request)
      ApplicationController.any_instance.stubs(:process_action).returns(nil)
    end

    it "filters parameters" do
      @controller.class.filter_parameters :name, :id
      @controller.process_action("")
      assert_equal @request.filtered_parameters['foo'], 'foo'
      assert_includes @request.filtered_parameters['name'], 'FILTERED'
      assert_includes @request.filtered_parameters['id'], 'FILTERED'
    end

    it "doesn't filter when filter_parameters isn't set" do
      @controller.class.filter_parameters nil
      @controller.process_action("")
      assert_equal @request.filtered_parameters, @params
    end

    it "doesn't filter when params don't match" do
      @controller.class.filter_parameters :description, :something
      @controller.process_action("")
      assert_equal @request.filtered_parameters, @params
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

  context 'controllers should be connected to resource' do
    it 'finds the right resource' do
      actual_resource = @controller.resource_class

      assert_equal(actual_resource, TestableResource)
    end

    it 'creates valid scope' do
      actual_scope = @controller.resource_scope

      assert actual_scope.is_a?(ActiveRecord::Relation)
    end

    it 'creates authorized scope' do
      mock_scope = mock('mock_scope')

      auth_scope = mock('auth_scope')
      auth_scope.stubs(:where).returns(mock_scope)

      resource_class = mock('authorized_resource')
      resource_class.stubs(:authorized).returns(auth_scope)

      @controller.stubs(:resource_class).returns(resource_class)
      @controller.stubs(:action_permission).returns('my_action')

      actual_scope = @controller.resource_scope

      assert_equal(actual_scope, mock_scope)
    end

    it 'creates valid scope with options' do
      actual_scope = @controller.resource_scope(field1: 'value1')

      assert_equal 'value1', actual_scope.where_values_hash['field1']
    end
  end

  context 'migration checker' do
    teardown do
      Foreman::Controller::MigrationChecker.instance_variable_set('@needs_migration', nil)
      ActiveRecord::Migrator.unstub(:needs_migration?)
    end

    it 'fails when pending migrations' do
      Foreman::Controller::MigrationChecker.instance_variable_set('@needs_migration', nil)
      ActiveRecord::Migrator.stubs(:needs_migration?).returns(true)
      get :index
      assert_response :service_unavailable
    end
  end

  context 'welcome page' do
    it 'shows a welcome page' do
      Realm.destroy_all # Realm is our TestableResource
      get :index, {}, set_session_user
      assert_response :success
      assert_template 'welcome'
    end

    it 'does not shows a welcome page when there is content' do
      FactoryGirl.create(:realm) # Realm is our TestableResource
      get :index, {}, set_session_user
      assert_response :success
      assert_template :partial => false
    end
  end
end

class Testscope::TestableResourcesControllerTest < ActionController::TestCase
  tests Testscope::TestableResourcesController

  context 'welcome page' do
    it 'shows a welcome page' do
      Realm.destroy_all # Realm is our Testscope::TestableResource
      get :index, {}, set_session_user
      assert_response :success
      assert_template 'welcome'
    end
  end
end
