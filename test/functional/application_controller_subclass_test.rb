require 'test_helper'

class ::TestableController < ::ApplicationController
  def index
    render :text => 'dummy', :status => 200
  end
end

class TestableControllerTest < ActionController::TestCase
  tests ::TestableController

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
      assert_equal '/testable', session[:original_uri]
    end

    context "and SSO authenticates" do
      setup do
        @sso = mock('dummy_sso')
        @sso.stubs(:authenticated?).returns(true)
        @sso.stubs(:current_user).returns(users(:admin))
        @controller.stubs(:available_sso).returns(@sso)
      end

      it "sets the session user" do
        get :index
        assert_response :success
        assert_equal users(:admin).id, session[:user]
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
      @request =  OpenStruct.new({:filtered_parameters => @params.clone })
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

  context "secure headers in HTTP response" do
    it "should include safe values" do
      get :index
      assert_equal @response.headers['X-Frame-Options'], 'SAMEORIGIN'
      assert_equal @response.headers['X-XSS-Protection'], '1; mode=block'
      assert_equal @response.headers['X-Content-Type-Options'], 'nosniff'
      assert_equal @response.headers['Content-Security-Policy'], \
        "default-src 'self'; connect-src 'self' ws://; font-src 'self'; " +
        "frame-src 'self'; img-src 'self' *.gravatar.com data:; media-src 'self'; " +
        "object-src 'self'; script-src 'unsafe-eval' 'unsafe-inline' " +
        "'self'; style-src 'unsafe-inline' 'self';"
    end
  end
end
