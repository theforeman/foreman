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

  context "API authentication" do
    setup do
      User.current = nil
      SETTINGS[:login] = false
    end

    teardown do
      SETTINGS[:login] = true
    end

    it "does not need an username and password when Settings[:login]=false" do
      get :index
      assert_response :success
    end

    it "does not set session data for API requests" do
      get :index
      assert_not session[:user]
    end
  end

  context 'errors' do
   test "top level key is error, no metadata included" do
      get :raise_error
      assert_equal ['error'], ActiveSupport::JSON.decode(@response.body).keys
    end
  end
end
