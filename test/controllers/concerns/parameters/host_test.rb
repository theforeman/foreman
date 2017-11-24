require 'test_helper'

class HostParametersTest < ActiveSupport::TestCase
  include Foreman::Controller::Parameters::Host

  let(:context) { Foreman::ParameterFilter::Context.new(:api, 'host', 'create') }
  let(:ui_context) { Foreman::ParameterFilter::Context.new(:ui, 'host', 'create') }
  let(:controller_name) { 'hosts' }

  test "passes through :compute_attributes hash untouched" do
    inner_params = {:name => 'test.example.com', :compute_attributes => {:foo => 'bar', :memory => 2}}
    expects(:params).at_least_once.returns(ActionController::Parameters.new(:host => inner_params))
    expects(:parameter_filter_context).returns(context)
    filtered = host_params

    assert_equal 'test.example.com', filtered['name']
    assert_equal({'foo' => 'bar', 'memory' => 2}, filtered['compute_attributes'].to_h)
  end

  test "correctly passes through :interfaces_attributes :compute_attributes hash" do
    inner_params = {:name => 'test.example.com', :interfaces_attributes => [{:name => 'abc', :compute_attributes => {:type => 'awesome', :network => 'superawesome'}}]}
    expects(:params).at_least_once.returns(ActionController::Parameters.new(:host => inner_params))
    expects(:parameter_filter_context).returns(ui_context)
    filtered = host_params

    assert_equal 'test.example.com', filtered['name']
    assert_equal 'abc', filtered['interfaces_attributes'][0][:name]
    assert_equal({'type' => 'awesome', 'network' => 'superawesome'}, filtered['interfaces_attributes'][0]['compute_attributes'].to_h)
  end
end
