require 'test_helper'

class HostParametersTest < ActiveSupport::TestCase
  include Foreman::Controller::Parameters::Host

  let(:context) { Foreman::ParameterFilter::Context.new(:api, 'host', 'create') }
  let(:ui_context) { Foreman::ParameterFilter::Context.new(:ui, 'host', 'create') }
  let(:controller_name) { 'hosts' }

  test "passes through :compute_attributes hash untouched" do
    inner_params = {:name => 'test.example.com', :compute_attributes => {:foo => 'bar', :memory => 2}}
    expects(:params).at_least_once.returns(ActionController::Parameters.new(:host => inner_params))
    expects(:parameter_filter_context).at_least_once.returns(context)
    filtered = host_params

    assert_equal 'test.example.com', filtered['name']
    assert_equal({'foo' => 'bar', 'memory' => 2}, filtered['compute_attributes'].to_h)
  end

  test "correctly passes through :interfaces_attributes :compute_attributes hash" do
    inner_params = {:name => 'test.example.com', :interfaces_attributes => [{:name => 'abc', :compute_attributes => {:type => 'awesome', :network => 'superawesome'}}]}
    expects(:params).at_least_once.returns(ActionController::Parameters.new(:host => inner_params))
    expects(:parameter_filter_context).at_least_once.returns(ui_context)
    filtered = host_params

    assert_equal 'test.example.com', filtered['name']
    assert_equal 'abc', filtered['interfaces_attributes'][0][:name]
    assert_equal({'type' => 'awesome', 'network' => 'superawesome'}, filtered['interfaces_attributes'][0]['compute_attributes'].to_h)
  end

  test 'normalizes json scsi attributes' do
    inner_params = {:name => 'test.example.com', :compute_attributes => {"scsi_controllers" => "{\"scsiControllers\":[{\"type\":\"VirtualLsiLogicController\",\"key\":1000}],\"volumes\":[{\"thin\":true,\"name\":\"Hard disk\",\"mode\":\"persistent\",\"controllerKey\":1000,\"size\":10485760,\"sizeGb\":10,\"storagePod\":\"Example-Pod\"}]}"}}
    expects(:params).at_least_once.returns(ActionController::Parameters.new(:host => inner_params))
    expects(:parameter_filter_context).at_least_once.returns(ui_context)
    filtered = host_params

    assert_equal 'test.example.com', filtered['name']
    assert_equal [{"type" => "VirtualLsiLogicController", "key" => 1000}], filtered['compute_attributes']['scsi_controllers']
    assert_equal({"0" => {"thin" => true, "name" => "Hard disk", "mode" => "persistent", "controller_key" => 1000, "size" => 10485760, "size_gb" => 10, "storage_pod" => "Example-Pod"}}, filtered['compute_attributes']['volumes_attributes'])
  end
end
