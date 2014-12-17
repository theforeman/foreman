require 'test_helper'

module MyPluginStrongParamsHelper
  include StrongParametersHelper

  def permitted_testable_strong_param_attributes
    permitted_common_parameter_attributes
  end
end

class TestableStrongParamsController < ApplicationController
  include MyPluginStrongParamsHelper
  ActionController::Parameters.action_on_unpermitted_parameters = :raise
  def create
    foreman_params
    head :ok
  end
end

class TestableStrongParamsControllerTest < ActionController::TestCase
  tests TestableStrongParamsController

  test 'missing required params will return bad request' do
    assert_raise ActionController::ParameterMissing do
      post :create, {:testable => {:name => "require"}}, set_session_user
    end
  end

  test 'empty params will return bad bad request' do
    assert_raise ActionController::ParameterMissing do
      post :create, { :testable_strong_param => {} }, set_session_user
    end
  end

  test 'valid params of another controller will return bad request' do
    assert_raise ActionController::ParameterMissing do
      post :create, { :host => { :name => "para" } }, set_session_user
    end
  end

  test 'valid params will be cleared' do
    post :create, { :testable_strong_param => { :name => "para", :value => "meter", :hidden_value => true } }, set_session_user
    assert_response :ok
  end
end
