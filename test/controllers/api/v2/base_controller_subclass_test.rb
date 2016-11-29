require 'test_helper'

class Api::V2::TestableController < Api::V2::BaseController
  def index
    render :text => 'dummy', :status => 200
  end

  def create
    render :text => 'dummy', :status => 200
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
      SETTINGS[:login] = true

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
end
