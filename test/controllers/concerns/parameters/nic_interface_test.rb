require 'test_helper'

class NicInterfaceParametersTest < ActiveSupport::TestCase
  include Foreman::Controller::Parameters::NicInterface

  let(:context) { Foreman::ParameterFilter::Context.new(:api, 'interface', 'create') }
  let(:controller_name) { 'interfaces' }

  test "passes through :compute_attributes hash untouched" do
    inner_params = {:name => 'test.example.com', :compute_attributes => {:foo => 'bar', :memory => 2}}
    expects(:params).at_least_once.returns(ActionController::Parameters.new(:interface => inner_params))
    expects(:parameter_filter_context).returns(context)
    filtered = nic_interface_params

    assert_equal 'test.example.com', filtered['name']
    assert_equal({'foo' => 'bar', 'memory' => 2}, filtered['compute_attributes'].to_h)
  end

  ['eth0,eth1', ['eth0', 'eth1']].each do |input|
    test "passes through :attached_devices => #{input.class.name}" do
      inner_params = {:name => 'test.example.com', :attached_devices => input}
      expects(:params).at_least_once.returns(ActionController::Parameters.new(:interface => inner_params))
      expects(:parameter_filter_context).returns(context)
      filtered = nic_interface_params

      assert_equal 'test.example.com', filtered['name']
      assert_equal input, filtered['attached_devices']
    end
  end
end
