require 'test_helper'

class KeepParamParametersTest < ActiveSupport::TestCase
  include Foreman::Controller::Parameters::KeepParam

  test "retains parameter within top-level hash" do
    params = ActionController::Parameters.new(:user => {:login => 'foo'})
    returned = keep_param(params, 'user', :login) { {} }
    assert_equal 'foo', returned[:login]
  end

  test "retains multiple parameters" do
    params = ActionController::Parameters.new(:user => {:login => 'foo', :other => 'bar'})
    returned = keep_param(params, 'user', :login, :other) { {} }
    assert_equal 'foo', returned[:login]
    assert_equal 'bar', returned[:other]
  end

  test "ignores unknown parameters" do
    params = ActionController::Parameters.new(:user => {:login => 'foo'})
    returned = keep_param(params, 'user', :login, :other) { {} }
    assert_equal 'foo', returned[:login]
    refute returned.has_key?(:other)
  end

  test "doesn't modify input hash" do
    params = ActionController::Parameters.new(:user => {:login => 'foo'})
    returned = keep_param(params, 'user', :login) { {:login => 'foo'} }
    assert_equal 'foo', returned[:login]
    assert_equal 'foo', params[:user][:login]
  end
end
