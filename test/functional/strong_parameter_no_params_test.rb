require 'test_helper'

## No strong parameters keys are given. All tests should raise a Foreman::Exception

class TestableNoParamsController < ApplicationController
  ActionController::Parameters.action_on_unpermitted_parameters = :raise
  def create
    foreman_params
    head :ok
  end
end

class TestableNoParamsControllerTest < ActionController::TestCase
  tests TestableNoParamsController

  test 'empty params will raise exception' do
    assert_raises Foreman::Exception do
      post :create, { :no_param => {} }, set_session_user
    end
  end

  test 'with params will raise exception' do
    assert_raises Foreman::Exception do
      post :create, { :no_param => { :name => "para", :value => "meter", :hidden_value => true } }, set_session_user
    end
  end

  test 'with valid host params, will raise exception' do
    assert_raises Foreman::Exception do
      post :create, { :host => { :name => "para" } }, set_session_user
    end
  end
end
