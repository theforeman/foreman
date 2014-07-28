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
end
